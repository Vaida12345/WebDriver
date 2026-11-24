//
//  Tests.swift
//  WebDriver
//
//  Created by Vaida on 3/6/25.
//

import Testing
import WebDriver


@Suite
struct WebDriverTests {
    
    @Test func example() async throws {
        let driver = try WebDriver.Firefox()
        let session = try await driver.startSession()
        
        try await session.open("http://example.com")
        
        let learnMore = try await session.window.findElement(where: { $0.text == "Learn more" })
        #expect(try await learnMore.isClickable)
        #expect(try await learnMore.tag == "a")
        
        try await session.close()
    }

    @Test func waitingTimeoutSnapshot() async throws {
        let driver = try WebDriver.Firefox()
        let session = try await driver.startSession()

        try await session.open("http://example.com")

        let error = await #expect(throws: Session.Window.WaitingTimeout.self) {
            try await session.window.wait(until: .elementPresence, timeout: .seconds(1), where: { $0.id == "does-not-exist" })
        }
        let details = try #require(error?.details)
        #expect(details.contains("<style>…("))
        #expect(details.contains("Learn more"))
        #expect(!details.contains("font-family"))

        try await session.close()
    }
}
