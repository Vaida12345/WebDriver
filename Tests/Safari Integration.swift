//
//  Safari Integration.swift
//  WebDriver
//
//  Created by Claude on 11/24/26.
//

import Foundation
import Testing
@testable
import WebDriver


/// Runs against the real `safaridriver` and Safari. Opt in with `SAFARI_INTEGRATION=1`.
///
/// Remote automation must be allowed, with `safaridriver --enable` or Safari's Develop menu. Safari opens a visible window while the tests run.
///
/// > Important:
/// > Run the tests from a regular terminal, such as Terminal.app, where `swift test` works. Processes started from the Claude app cannot launch Safari: creating the session times out while "finding or launching a compatible local Safari".
@Suite(.serialized, .enabled(if: ProcessInfo.processInfo.environment["SAFARI_INTEGRATION"] == "1" && WebDriver.Safari.isAvailable))
struct SafariIntegrationTests {

    @Test(.timeLimit(.minutes(1)))
    func sessionRoundTrip() async throws {
        let session = try await WebDriver.Safari().startSession()
        let port = session.launcher.port
        #expect(processCount(matching: "safaridriver -p \(port)") == 1)

        do {
            try await session.open(url: URL(string: "data:text/html,<html><body><p id='greeting'>Hello</p></body></html>")!)
            let window = try await session.window

            let element = try await window.findElement(where: { $0.id == "greeting" })
            #expect(try await element.summary == #"<p id="greeting">Hello</p>"#)

            let image = try await window.screenshot()
            #expect(image.size.width > 0 && image.size.height > 0)

            await #expect(throws: WebDriverError.self) {
                try await window.screenshot(fullPage: true)
            }
        } catch {
            try? await session.close()
            throw error
        }

        try await session.close()
        #expect(processCount(matching: "safaridriver -p \(port)") == 0)
    }

}


private func processCount(matching pattern: String) -> Int {
    let process = Process()
    let pipe = Pipe()
    process.executableURL = URL(filePath: "/usr/bin/pgrep")
    process.arguments = ["-f", pattern]
    process.standardOutput = pipe
    try? process.run()
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    process.waitUntilExit()
    return String(decoding: data, as: UTF8.self).split(separator: "\n").count
}
