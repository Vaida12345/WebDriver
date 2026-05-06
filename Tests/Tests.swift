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
}
