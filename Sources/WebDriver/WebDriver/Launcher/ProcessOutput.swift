//
//  ProcessOutput.swift
//  WebDriver
//
//  Created by Claude on 11/24/26.
//

import Foundation
import os


/// Drains the output of a child process into a bounded buffer, and tracks when the process exits.
///
/// Reading the output continuously keeps the pipe from filling up, which would otherwise block the child on its next write.
final class ProcessOutput: Sendable {

    /// An event that ``wait(for:timeout:)`` can wait for.
    enum Event: Sendable {
        /// The process exited.
        case exit
        /// The process and every descendant holding the pipe closed it.
        case endOfOutput
    }

    /// The maximum number of bytes kept. Older output is dropped first.
    let capacity: Int

    private let state = OSAllocatedUnfairLock(initialState: State())


    init(capacity: Int = 64 * 1024) {
        self.capacity = capacity
    }


    /// The exit status of the process, or `nil` while it is running.
    var exitStatus: Int32? {
        self.state.withLock { $0.exitStatus }
    }

    /// Connects the output and termination of `process` to `self`.
    ///
    /// Call this before `run()`. After launching, close the writing end of the returned pipe, so that end of output can be detected.
    func attach(to process: Process) -> Pipe {
        let pipe = Pipe()
        process.standardInput = FileHandle.nullDevice
        process.standardOutput = pipe
        process.standardError = pipe

        pipe.fileHandleForReading.readabilityHandler = { [self] handle in
            let data = handle.availableData
            if data.isEmpty {
                handle.readabilityHandler = nil
                self.recordEndOfOutput()
            } else {
                self.append(data)
            }
        }
        process.terminationHandler = { [self] process in
            self.recordExit(status: process.terminationStatus)
        }
        return pipe
    }

    /// Appends `data`, dropping the oldest bytes beyond ``capacity``.
    func append(_ data: Data) {
        let capacity = self.capacity
        self.state.withLock { state in
            state.buffer.append(data)
            if state.buffer.count > capacity {
                state.buffer = Data(state.buffer.suffix(capacity))
            }
        }
    }

    /// Returns the last `lines` lines of output.
    func tail(lines: Int) -> String {
        let buffer = self.state.withLock { $0.buffer }
        let text = String(decoding: buffer, as: UTF8.self)
        return text.split(separator: "\n", omittingEmptySubsequences: false)
            .suffix(lines + 1) // the output usually ends with a newline
            .joined(separator: "\n")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Runs `handler` once the process exits, or immediately if it already has.
    ///
    /// Handlers run before ``wait(for:timeout:)`` returns for ``Event/exit``.
    func onExit(_ handler: @escaping @Sendable () -> Void) {
        let hasExited = self.state.withLock { state in
            guard state.exitStatus == nil else { return true }
            state.exitHandlers.append(handler)
            return false
        }
        if hasExited { handler() }
    }

    /// Waits until `event` happens or `timeout` passes.
    ///
    /// - Returns: Whether `event` happened.
    func wait(for event: Event, timeout: Duration) async -> Bool {
        let id = UUID()
        return await withCheckedContinuation { continuation in
            let hasHappened = self.state.withLock { state in
                guard !state.hasHappened(event) else { return true }
                state.waiters[id] = Waiter(event: event, continuation: continuation)
                return false
            }
            guard !hasHappened else {
                continuation.resume(returning: true)
                return
            }

            Task {
                try? await Task.sleep(for: timeout)
                let waiter = self.state.withLock { $0.waiters.removeValue(forKey: id) }
                waiter?.continuation.resume(returning: false)
            }
        }
    }

    func recordExit(status: Int32) {
        let (handlers, waiters) = self.state.withLock { state in
            guard state.exitStatus == nil else { return ([@Sendable () -> Void](), [Waiter]()) }
            state.exitStatus = status
            defer { state.exitHandlers = [] }
            return (state.exitHandlers, state.removeWaiters(for: .exit))
        }
        handlers.forEach { $0() }
        waiters.forEach { $0.continuation.resume(returning: true) }
    }

    private func recordEndOfOutput() {
        let waiters = self.state.withLock { state in
            state.isEndOfOutput = true
            return state.removeWaiters(for: .endOfOutput)
        }
        waiters.forEach { $0.continuation.resume(returning: true) }
    }


    private struct Waiter: Sendable {
        let event: Event
        let continuation: CheckedContinuation<Bool, Never>
    }

    private struct State: Sendable {
        var buffer = Data()
        var exitStatus: Int32?
        var isEndOfOutput = false
        var exitHandlers: [@Sendable () -> Void] = []
        var waiters: [UUID : Waiter] = [:]

        func hasHappened(_ event: Event) -> Bool {
            switch event {
            case .exit: self.exitStatus != nil
            case .endOfOutput: self.isEndOfOutput
            }
        }

        mutating func removeWaiters(for event: Event) -> [Waiter] {
            let matching = self.waiters.filter { $0.value.event == event }
            for key in matching.keys {
                self.waiters.removeValue(forKey: key)
            }
            return Array(matching.values)
        }
    }

}
