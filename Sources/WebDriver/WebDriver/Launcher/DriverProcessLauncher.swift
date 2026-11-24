//
//  DriverProcessLauncher.swift
//  WebDriver
//
//  Created by Vaida on 3/4/25.
//

import Foundation
import OSLog
import JSONParser
import os


private let logger = Logger(subsystem: "WebDriver", category: "DriverProcessLauncher")

/// The host that launched drivers listen on.
let driverLoopback = "127.0.0.1"


/// Launches and owns a local WebDriver server process, such as `geckodriver` or `safaridriver`.
final class DriverProcessLauncher<Driver: WebDriverProtocol>: WebDriverLauncher {

    /// The driver used for this launch, whose capabilities are sent when creating the session.
    public let driver: Driver

    public let host: String = driverLoopback

    public let port: UInt16

    /// The name of the driver executable, used in logs and errors.
    private let name: String

    private let process: Process

    private let output: ProcessOutput

    private let state = OSAllocatedUnfairLock(initialState: State())


    public func attach(sessionID: String) {
        self.state.withLock { $0.sessionID = sessionID }
    }

    /// Stops the driver process, waiting for it to exit.
    ///
    /// Call it after the session was deleted, so that the driver has already closed the browser.
    public func stop() async {
        guard self.markStopped() != nil else { return }
        await DriverProcess.terminate(pid: self.process.processIdentifier, output: self.output, name: self.name)
    }


    /// Launches the driver process, waiting until it is ready.
    ///
    /// - Parameters:
    ///   - driver: The driver whose capabilities are sent when creating the session.
    ///   - name: The name of the driver executable, used in logs and errors.
    ///   - executable: The path to the driver executable.
    ///   - arguments: The arguments for an attempt that listens on the given port, on ``driverLoopback``.
    ///   - onExit: Cleanup that runs once the process has exited, or when launching fails.
    ///   - maxRetryCount: Number of random-port attempts before failing.
    init(
        driver: Driver,
        name: String,
        executable: String,
        arguments: (_ port: UInt16) -> [String],
        onExit: @escaping @Sendable () -> Void = {},
        maxRetryCount: Int = 3
    ) async throws {
        self.driver = driver
        self.name = name

        let retryCount = max(1, maxRetryCount)
        var lastFailure = ""

        for attempt in 1...retryCount {
            let port = generateRandomPort()

            let output = ProcessOutput()
            let process = Process()
            process.executableURL = URL(filePath: executable)
            process.arguments = arguments(port)
            let pipe = output.attach(to: process)

            do {
                try process.run()
            } catch {
                onExit()
                logger.error("Failed to spawn \(name) at \(executable): \(error)")
                throw WebDriver.InitializationError.driverStartFailed
            }
            // The child holds its own copy; closing ours lets end of output be detected.
            try? pipe.fileHandleForWriting.close()

            do {
                try await Self.waitUntilReady(port: port, output: output, name: name)
            } catch {
                await DriverProcess.terminate(pid: process.processIdentifier, output: output, name: name)
                // The last lines may still be in the pipe when the process exits.
                _ = await output.wait(for: .endOfOutput, timeout: .milliseconds(200))

                guard !(error is CancellationError) else {
                    onExit()
                    throw error
                }

                lastFailure = "\(error)\n\(output.tail(lines: 20))"
                logger.info("\(name) attempt \(attempt)/\(retryCount) failed: \(lastFailure)")
                continue
            }

            logger.info("\(name) launched at \(driverLoopback):\(port) (attempt \(attempt)/\(retryCount))")

            output.onExit(onExit)
            self.port = port
            self.process = process
            self.output = output
            return
        }

        onExit()
        logger.error("Failed to launch \(name) after \(retryCount) attempts: \(lastFailure)")
        throw WebDriver.InitializationError.exceededMaxRetries(retryCount, output: lastFailure)
    }

    /// Marks `self` as stopped.
    ///
    /// - Returns: `nil` if `self` was already stopped, otherwise the attached session id, if any.
    private func markStopped() -> String?? {
        self.state.withLock { state in
            guard !state.isStopped else { return nil }
            state.isStopped = true
            return .some(state.sessionID)
        }
    }


    /// Waits until the driver reports ready on `/status`.
    ///
    /// - Throws: ``LaunchFailure`` when the driver exits or does not become ready in time.
    private static func waitUntilReady(port: UInt16, output: ProcessOutput, name: String, timeout: Duration = .seconds(10)) async throws {
        let statusURL = makeBaseURL(host: driverLoopback, port: port)!.appending(path: "status")

        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = 1
        let session = URLSession(configuration: configuration)
        defer { session.invalidateAndCancel() }

        let deadline = ContinuousClock.now.advanced(by: timeout)
        while ContinuousClock.now < deadline {
            if let status = output.exitStatus {
                throw LaunchFailure.exited(name: name, status: status)
            }

            if let (data, response) = try? await session.data(from: statusURL),
               (response as? HTTPURLResponse)?.statusCode == 200,
               let status = try? Session.Status(parser: JSONParser(data: data)),
               status.isReady {
                return
            }

            try await Task.sleep(for: .milliseconds(100))
        }

        throw LaunchFailure.timedOut(name: name, timeout: timeout)
    }


    /// Ends the session and stops the driver when `self` is dropped without ``stop()``.
    ///
    /// This is best effort: if the program exits right away, the cleanup may not run. Call ``Session/close(fileID:line:function:)`` instead.
    deinit {
        guard let sessionID = self.markStopped() else { return }

        let pid = self.process.processIdentifier
        let output = self.output
        let name = self.name
        let baseURL = self.baseURL

        Task.detached {
            if let sessionID {
                // Deleting the session makes the driver close the browser, which SIGTERM alone may not.
                var request = URLRequest(url: baseURL.appending(path: "session/\(sessionID)"), timeoutInterval: 10)
                request.httpMethod = "DELETE"
                _ = try? await URLSession.shared.data(for: request)
            }
            await DriverProcess.terminate(pid: pid, output: output, name: name)
        }
    }


    private struct State: Sendable {
        var sessionID: String?
        var isStopped = false
    }

    /// The reason a launch attempt failed.
    private enum LaunchFailure: Error, CustomStringConvertible {
        case exited(name: String, status: Int32)
        case timedOut(name: String, timeout: Duration)

        var description: String {
            switch self {
            case .exited(let name, let status):
                "\(name) exited with status \(status)."
            case .timedOut(let name, let timeout):
                "\(name) did not become ready within \(timeout)."
            }
        }
    }

}


/// Process management shared by the launchers.
enum DriverProcess {

    /// Stops the process and the processes it started, sending `SIGTERM`, then `SIGKILL` to those still running after five seconds.
    ///
    /// The children, such as the Firefox that `geckodriver` launched, are found before the process is signaled. Once it exits, they are reparented to `launchd` and could no longer be found, so they would keep running.
    static func terminate(pid: pid_t, output: ProcessOutput, name: String) async {
        guard output.exitStatus == nil else { return }
        let children = childProcesses(of: pid)

        kill(pid, SIGTERM)
        for child in children {
            kill(child, SIGTERM)
        }

        if await !output.wait(for: .exit, timeout: .seconds(5)) {
            logger.error("\(name) did not exit after SIGTERM, sending SIGKILL.")
            kill(pid, SIGKILL)
            _ = await output.wait(for: .exit, timeout: .seconds(1))
        }

        let deadline = ContinuousClock.now.advanced(by: .seconds(5))
        var running = children
        while !running.isEmpty {
            running = running.filter { kill($0, 0) == 0 }
            guard !running.isEmpty else { break }
            guard ContinuousClock.now < deadline else {
                logger.error("Child processes \(running) of \(name) did not exit after SIGTERM, sending SIGKILL.")
                running.forEach { kill($0, SIGKILL) }
                break
            }
            try? await Task.sleep(for: .milliseconds(100))
        }
    }

    /// Returns the ids of the direct children of the process.
    static func childProcesses(of pid: pid_t) -> [pid_t] {
        var buffer = [pid_t](repeating: 0, count: 64)
        let count = buffer.withUnsafeMutableBytes {
            proc_listchildpids(pid, $0.baseAddress, Int32($0.count))
        }
        guard count > 0 else { return [] }
        return Array(buffer.prefix(Int(count))).filter { $0 > 0 }
    }

}
