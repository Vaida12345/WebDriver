//
//  Gecko Integration.swift
//  WebDriver
//
//  Created by Claude on 11/24/26.
//

import Foundation
import Testing
import FinderItem
@testable
import WebDriver


/// Runs against the installed `geckodriver` and Firefox. Opt in with `GECKO_INTEGRATION=1`.
@Suite(.serialized, .enabled(if: ProcessInfo.processInfo.environment["GECKO_INTEGRATION"] == "1" && WebDriver.Firefox.isAvailable))
struct GeckoIntegrationTests {

    /// Writes far more than a pipe buffer holds to geckodriver's output, then checks the session still responds.
    @Test(.timeLimit(.minutes(1)))
    func noisyOutputDoesNotHang() async throws {
        let session = try await WebDriver.Firefox().headless().startSession()
        let window = try await session.window
        // geckodriver enables `dump`, which writes to Firefox's stdout, which geckodriver forwards.
        _ = try await window.execute("const line = 'x'.repeat(1000) + '\\n'; for (let i = 0; i < 10000; i++) { dump(line) }")
        _ = try await session.status()
        _ = try await window.execute("return 1")
        try await session.close()
    }

    @Test(.timeLimit(.minutes(1)))
    func concurrentSessions() async throws {
        let driver = try WebDriver.Firefox().headless()
        async let first = driver.startSession()
        async let second = driver.startSession()
        let sessions = try await [first, second]

        let ports = sessions.map { webSocketPort(of: $0) }
        #expect(ports[0] != nil && ports[1] != nil && ports[0] != ports[1])

        for session in sessions {
            _ = try await session.window.execute("return 1")
            try await session.close()
        }
    }

    @Test(.timeLimit(.minutes(1)))
    func copiedProfilesArePerSessionAndDeleted() async throws {
        let template = FinderItem.temporaryDirectory/"\(UUID()).template"
        try FileManager.default.createDirectory(atPath: template.path, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(atPath: template.path) }

        let driver = try WebDriver.Firefox().headless().profile(location: template)
        let first = try await driver.startSession()
        let second = try await driver.startSession()

        let paths = [first, second].map { ($0.launcher.driver as! WebDriver.Firefox).firefoxArg(after: "-profile")! }
        #expect(paths[0] != paths[1])
        #expect(paths.allSatisfy { $0.hasSuffix(".tempprofile") && FileManager.default.fileExists(atPath: $0) })

        try await first.close()
        #expect(!FileManager.default.fileExists(atPath: paths[0]))
        #expect(FileManager.default.fileExists(atPath: paths[1]))
        try await second.close()
        #expect(!FileManager.default.fileExists(atPath: paths[1]))
        #expect(FileManager.default.fileExists(atPath: template.path))
    }

    @Test(.timeLimit(.minutes(1)))
    func droppedSessionClosesFirefox() async throws {
        let template = FinderItem.temporaryDirectory/"\(UUID()).template"
        try FileManager.default.createDirectory(atPath: template.path, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(atPath: template.path) }

        var session: Session? = try await WebDriver.Firefox().headless().profile(location: template).startSession()
        let profile = (session!.launcher.driver as! WebDriver.Firefox).firefoxArg(after: "-profile")!
        #expect(processCount(matching: profile) > 0)

        session = nil
        _ = session

        let deadline = ContinuousClock.now + .seconds(20)
        while ContinuousClock.now < deadline, processCount(matching: profile) > 0 || FileManager.default.fileExists(atPath: profile) {
            try await Task.sleep(for: .milliseconds(200))
        }
        #expect(processCount(matching: profile) == 0)
        #expect(!FileManager.default.fileExists(atPath: profile))
    }

    @Test(.timeLimit(.minutes(1)))
    func failingDriverFailsFast() async throws {
        setenv("WEBDRIVER_GECKO_PATH", "/usr/bin/false", 1)
        defer { unsetenv("WEBDRIVER_GECKO_PATH") }

        let start = ContinuousClock.now
        await #expect {
            _ = try await WebDriver.Firefox().startSession()
        } throws: { error in
            guard case WebDriver.InitializationError.exceededMaxRetries(3, let output) = error else { return false }
            return output.contains("exited with status 1")
        }
        #expect(ContinuousClock.now - start < .seconds(3))
    }

}


/// Reads the `--websocket-port` that the session's geckodriver was launched with.
private func webSocketPort(of session: Session) -> String? {
    let port = session.launcher.port
    let lines = shell("/bin/ps", "-axo", "args=").split(separator: "\n")
    guard let line = lines.first(where: { $0.contains("geckodriver") && $0.contains("-p \(port)") }) else { return nil }
    let parts = line.split(separator: " ")
    guard let index = parts.firstIndex(of: "--websocket-port"), index + 1 < parts.count else { return nil }
    return String(parts[index + 1])
}

private func processCount(matching pattern: String) -> Int {
    shell("/usr/bin/pgrep", "-f", pattern).split(separator: "\n").count
}

private func shell(_ executable: String, _ arguments: String...) -> String {
    let process = Process()
    let pipe = Pipe()
    process.executableURL = URL(filePath: executable)
    process.arguments = arguments
    process.standardOutput = pipe
    try? process.run()
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    process.waitUntilExit()
    return String(decoding: data, as: UTF8.self)
}
