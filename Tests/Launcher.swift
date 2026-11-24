//
//  Launcher.swift
//  WebDriver
//
//  Created by Claude on 11/24/26.
//

import Foundation
import Testing
import FinderItem
import os
@testable
import WebDriver


extension Tag {
    @Tag static var launcher: Tag
}


@Suite(.tags(.launcher))
struct LauncherTests {

    @Test
    func outputKeepsOnlyTheTail() {
        let output = ProcessOutput(capacity: 10)
        output.append(Data("0123456789".utf8))
        output.append(Data("abc".utf8))
        #expect(output.tail(lines: 1) == "3456789abc")
    }

    @Test
    func outputTailLines() {
        let output = ProcessOutput()
        output.append(Data("one\ntwo\nthree\n".utf8))
        #expect(output.tail(lines: 2) == "two\nthree")
        #expect(output.tail(lines: 10) == "one\ntwo\nthree")
    }

    @Test
    func exitStatusIsRecorded() async throws {
        let output = ProcessOutput()
        let process = Process()
        process.executableURL = URL(filePath: "/bin/sh")
        process.arguments = ["-c", "echo hello; exit 3"]
        let pipe = output.attach(to: process)
        try process.run()
        try? pipe.fileHandleForWriting.close()

        #expect(await output.wait(for: .exit, timeout: .seconds(5)))
        #expect(output.exitStatus == 3)
        #expect(await output.wait(for: .endOfOutput, timeout: .seconds(5)))
        #expect(output.tail(lines: 1) == "hello")
    }

    @Test
    func waitTimesOut() async throws {
        let output = ProcessOutput()
        let process = Process()
        process.executableURL = URL(filePath: "/bin/sleep")
        process.arguments = ["10"]
        _ = output.attach(to: process)
        try process.run()
        defer { process.terminate() }

        let start = ContinuousClock.now
        #expect(await !output.wait(for: .exit, timeout: .milliseconds(200)))
        #expect(ContinuousClock.now - start < .seconds(5))
        #expect(output.exitStatus == nil)
    }

    @Test
    func exitHandlersRunBeforeWaitersResume() async throws {
        let output = ProcessOutput()
        let ran = Flag()
        output.onExit { ran.set() }
        output.recordExit(status: 0)
        #expect(await output.wait(for: .exit, timeout: .seconds(1)))
        #expect(ran.value)

        let late = Flag()
        output.onExit { late.set() }
        #expect(late.value)
    }

    /// A grandchild, like the Firefox started by geckodriver, must not outlive the terminated child.
    @Test(.timeLimit(.minutes(1)))
    func terminateStopsChildProcesses() async throws {
        let output = ProcessOutput()
        let process = Process()
        process.executableURL = URL(filePath: "/bin/sh")
        process.arguments = ["-c", "/bin/sleep 30 & wait"]
        _ = output.attach(to: process)
        try process.run()

        var children: [pid_t] = []
        let deadline = ContinuousClock.now + .seconds(5)
        while children.isEmpty, ContinuousClock.now < deadline {
            try await Task.sleep(for: .milliseconds(50))
            children = DriverProcess.childProcesses(of: process.processIdentifier)
        }
        try #require(children.count == 1)

        await DriverProcess.terminate(pid: process.processIdentifier, output: output, name: "sh")
        #expect(output.exitStatus != nil)
        #expect(kill(children[0], 0) != 0)
    }

    @Test
    func profileNameIsPassedVerbatim() throws {
        let driver = try WebDriver.Firefox().profile(named: "a b")
        #expect(try driver.firefoxArgs() == ["-P", "a b"])
    }

    @Test
    func copiedProfileSurvivesChaining() throws {
        let driver = try WebDriver.Firefox()
            .profile(location: FinderItem(at: "/tmp/template"))
            .headless()
            .pageLoadStrategy(.eager)
        #expect(driver.flags.contains(.copyProfileOnLaunch))
        #expect(driver.firefoxArg(after: "-profile") == "/tmp/template")
    }

    @Test
    func lastProfileWins() throws {
        let driver = try WebDriver.Firefox()
            .profile(location: FinderItem(at: "/tmp/a"))
            .profile(noCopying: FinderItem(at: "/tmp/b"))
        #expect(try driver.firefoxArgs() == ["-profile", "/tmp/b"])
        #expect(!driver.flags.contains(.copyProfileOnLaunch))
    }

    /// A launcher whose session fails to start is stopped before the error is rethrown, so that its cleanup, such as deleting a copied profile, has run.
    @MainActor
    @Test
    func failedSessionStopsTheLauncher() async throws {
        let browser = try await MockBrowser(html: "<html><body></body></html>")
        browser.sessionCreationError = "This version of ChromeDriver only supports Chrome version 158"
        let launcher = RecordingLauncher(driver: try WebDriver.Chrome(), host: browser.id)
        
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockWebDriverProtocol.self]
        let error = await #expect(throws: WebDriverError.self) {
            try await launcher.startSession(context: .unavailable, invoker: #function, urlSessionConfiguration: configuration)
        }
        #expect(error?.code == .session_not_created)
        #expect(error?.message.contains("only supports Chrome version 158") == true)
        #expect(launcher.stopCount == 1)
    }

    @Test
    func baseURL() {
        #expect(makeBaseURL(host: "127.0.0.1", port: 4444)?.absoluteString == "http://127.0.0.1:4444")
        #expect(makeBaseURL(host: "127.0.0.1", port: 4444)?.appending(path: "status").absoluteString == "http://127.0.0.1:4444/status")
    }

}


/// A launcher for a server that is already running, which records calls to ``stop()``.
private final class RecordingLauncher<Driver: WebDriverProtocol>: WebDriverLauncher {
    
    let driver: Driver
    
    let host: String
    
    let port: UInt16 = 4444
    
    private let stops = OSAllocatedUnfairLock(initialState: 0)
    
    var stopCount: Int { stops.withLock { $0 } }
    
    init(driver: Driver, host: String) {
        self.driver = driver
        self.host = host
    }
    
    func attach(sessionID: String) {}
    
    func stop() async {
        stops.withLock { $0 += 1 }
    }
    
}


private final class Flag: Sendable {
    private let storage = OSAllocatedUnfairLock(initialState: false)
    var value: Bool { storage.withLock { $0 } }
    func set() { storage.withLock { $0 = true } }
}
