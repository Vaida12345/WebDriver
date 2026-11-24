//
//  GeckoLauncher.swift
//  WebDriver
//
//  Created by Vaida on 3/4/25.
//

import Foundation
import OSLog
import FinderItem
import JSONParser
import os


final class GeckoLauncher: WebDriverLauncher {

    private static let logger = Logger(subsystem: "WebDriver", category: "GeckoLauncher")

    private static let loopback = "127.0.0.1"

    /// The driver used for this launch. When the profile is copied, its `-profile` points to the copy.
    public let driver: WebDriver.Firefox

    public let host: String = GeckoLauncher.loopback

    public let port: UInt16

    private let process: Process

    private let output: ProcessOutput

    private let state = OSAllocatedUnfairLock(initialState: State())


    public func attach(sessionID: String) {
        self.state.withLock { $0.sessionID = sessionID }
    }

    /// Stops `geckodriver`, waiting for it to exit.
    ///
    /// Call it after the session was deleted, so that `geckodriver` has already closed Firefox.
    public func stop() async {
        guard self.markStopped() != nil else { return }
        await Self.terminate(pid: self.process.processIdentifier, output: self.output)
    }


    /// Creates and launches a `geckodriver` process for the provided Firefox driver.
    ///
    /// - Parameters:
    ///   - driver: The configured Firefox driver.
    ///   - maxRetryCount: Number of random-port attempts before failing.
    init(driver: WebDriver.Firefox, maxRetryCount: Int = 3) async throws {
        guard let geckoDriverPath = WebDriver.Firefox.geckoDriverPath else {
            throw WebDriver.InitializationError.driverNotAvailable
        }

        var driver = driver
        var temporaryProfile: String?
        if driver.flags.contains(.copyProfileOnLaunch), let template = driver.firefoxArg(after: "-profile") {
            let copy = FinderItem.temporaryDirectory/"\(UUID()).tempprofile"
            try FinderItem(at: template).copy(to: copy)
            temporaryProfile = copy.path
            driver = try driver.settingFirefoxArg("-profile", value: copy.path)
        }
        self.driver = driver

        let retryCount = max(1, maxRetryCount)
        var lastFailure = ""

        for attempt in 1...retryCount {
            let port = generateRandomPort()
            let bidiPort = generateRandomPort()

            let output = ProcessOutput()
            let process = Process()
            process.executableURL = URL(filePath: geckoDriverPath)
            process.arguments = ["--host", Self.loopback, "-p", port.description, "--websocket-port", bidiPort.description]
            let pipe = output.attach(to: process)

            do {
                try process.run()
            } catch {
                Self.removeProfile(at: temporaryProfile)
                Self.logger.error("Failed to spawn geckodriver at \(geckoDriverPath): \(error)")
                throw WebDriver.InitializationError.driverStartFailed
            }
            // The child holds its own copy; closing ours lets end of output be detected.
            try? pipe.fileHandleForWriting.close()

            do {
                try await Self.waitUntilReady(port: port, output: output)
            } catch {
                await Self.terminate(pid: process.processIdentifier, output: output)
                // The last lines may still be in the pipe when the process exits.
                _ = await output.wait(for: .endOfOutput, timeout: .milliseconds(200))

                guard !(error is CancellationError) else {
                    Self.removeProfile(at: temporaryProfile)
                    throw error
                }

                lastFailure = "\(error)\n\(output.tail(lines: 20))"
                Self.logger.info("geckodriver attempt \(attempt)/\(retryCount) failed: \(lastFailure)")
                continue
            }

            Self.logger.info("geckodriver launched at \(Self.loopback):\(port) (attempt \(attempt)/\(retryCount))")

            // Delete the copy only once geckodriver, which waits for Firefox when the session is deleted, has exited.
            output.onExit { [temporaryProfile] in
                Self.removeProfile(at: temporaryProfile)
            }

            self.port = port
            self.process = process
            self.output = output
            return
        }

        Self.removeProfile(at: temporaryProfile)
        Self.logger.error("Failed to launch geckodriver after \(retryCount) attempts: \(lastFailure)")
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


    /// Waits until `geckodriver` reports ready on `/status`.
    ///
    /// - Throws: ``LaunchFailure`` when `geckodriver` exits or does not become ready in time.
    private static func waitUntilReady(port: UInt16, output: ProcessOutput, timeout: Duration = .seconds(10)) async throws {
        let statusURL = makeBaseURL(host: Self.loopback, port: port)!.appending(path: "status")

        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = 1
        let session = URLSession(configuration: configuration)
        defer { session.invalidateAndCancel() }

        let deadline = ContinuousClock.now.advanced(by: timeout)
        while ContinuousClock.now < deadline {
            if let status = output.exitStatus {
                throw LaunchFailure.exited(status: status)
            }

            if let (data, response) = try? await session.data(from: statusURL),
               (response as? HTTPURLResponse)?.statusCode == 200,
               let status = try? Session.Status(parser: JSONParser(data: data)),
               status.isReady {
                return
            }

            try await Task.sleep(for: .milliseconds(100))
        }

        throw LaunchFailure.timedOut(timeout)
    }

    /// Stops the process and the processes it started, sending `SIGTERM`, then `SIGKILL` to those still running after five seconds.
    ///
    /// The children, such as the Firefox that `geckodriver` launched, are found before the process is signaled. Once it exits, they are reparented to `launchd` and could no longer be found, so they would keep running.
    static func terminate(pid: pid_t, output: ProcessOutput) async {
        guard output.exitStatus == nil else { return }
        let children = childProcesses(of: pid)

        kill(pid, SIGTERM)
        for child in children {
            kill(child, SIGTERM)
        }

        if await !output.wait(for: .exit, timeout: .seconds(5)) {
            logger.error("geckodriver did not exit after SIGTERM, sending SIGKILL.")
            kill(pid, SIGKILL)
            _ = await output.wait(for: .exit, timeout: .seconds(1))
        }

        let deadline = ContinuousClock.now.advanced(by: .seconds(5))
        var running = children
        while !running.isEmpty {
            running = running.filter { kill($0, 0) == 0 }
            guard !running.isEmpty else { break }
            guard ContinuousClock.now < deadline else {
                logger.error("Child processes \(running) of geckodriver did not exit after SIGTERM, sending SIGKILL.")
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

    private static func removeProfile(at path: String?) {
        guard let path else { return }
        do {
            try FileManager.default.removeItem(atPath: path)
        } catch {
            logger.fault("Failed to delete temporary profile at \(path): \(error)")
        }
    }


    /// Ends the session and stops `geckodriver` when `self` is dropped without ``stop()``.
    ///
    /// This is best effort: if the program exits right away, the cleanup may not run. Call ``Session/close(fileID:line:function:)`` instead.
    deinit {
        guard let sessionID = self.markStopped() else { return }

        let pid = self.process.processIdentifier
        let output = self.output
        let baseURL = self.baseURL

        Task.detached {
            if let sessionID {
                // Deleting the session makes geckodriver close Firefox, which SIGTERM alone does not.
                var request = URLRequest(url: baseURL.appending(path: "session/\(sessionID)"), timeoutInterval: 10)
                request.httpMethod = "DELETE"
                _ = try? await URLSession.shared.data(for: request)
            }
            await GeckoLauncher.terminate(pid: pid, output: output)
        }
    }


    private struct State: Sendable {
        var sessionID: String?
        var isStopped = false
    }

    /// The reason a launch attempt failed.
    private enum LaunchFailure: Error, CustomStringConvertible {
        case exited(status: Int32)
        case timedOut(Duration)

        var description: String {
            switch self {
            case .exited(let status):
                "geckodriver exited with status \(status)."
            case .timedOut(let timeout):
                "geckodriver did not become ready within \(timeout)."
            }
        }
    }

}
