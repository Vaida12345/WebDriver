//
//  Timeouts and Screenshots.swift
//  WebDriver
//
//  Created by Claude on 11/24/26.
//

import Foundation
import Testing
import JSONParser
@testable
import WebDriver


@Suite
struct TimeoutTests {

    @Test
    func encodesSetTimeoutsInMilliseconds() throws {
        let timeout = Session.Timeout(script: .milliseconds(1500), pageLoad: .zero)
        let encoded = try timeout.encode()
        #expect(encoded["script"] as? Int == 1500)
        #expect(encoded["pageLoad"] as? Int == 0)
        #expect(encoded["implicit"] == nil)
    }

    @Test
    func negativeTimeoutThrows() {
        #expect(throws: Session.Timeout.InvalidValue.self) {
            try Session.Timeout(implicit: .seconds(-1)).encode()
        }
    }

    @Test
    func decodesZeroAndNull() throws {
        let data = Data(#"{"value":{"script":null,"pageLoad":300000,"implicit":0}}"#.utf8)
        let timeout = try Session.Timeout(parser: JSONParser(data: data))
        #expect(timeout.script == nil)
        #expect(timeout.pageLoad == .seconds(300))
        #expect(timeout.implicit == .zero)
    }

    @Test
    func driverSendsTimeoutsCapability() throws {
        let driver = try WebDriver.Firefox()
            .timeouts(Session.Timeout(pageLoad: .seconds(30), implicit: .seconds(2)))
            .headless()
        let timeouts = try #require(driver.capabilities["timeouts"] as? [String : Any])
        #expect(timeouts["pageLoad"] as? Int == 30_000)
        #expect(timeouts["implicit"] as? Int == 2_000)
    }

    @Test
    @MainActor
    func timeoutsReachTheServerOnSessionStart() async throws {
        let browser = try await MockBrowser(html: "<html><body></body></html>")
        let driver = try WebDriver.Firefox().timeouts(Session.Timeout(script: .seconds(5)))
        _ = try await browser.startSession(driver: driver)
        let timeouts = try #require(browser.capabilities["timeouts"] as? [String : Any])
        #expect(timeouts["script"] as? Int == 5_000)
    }

}


@Suite
@MainActor
struct ScreenshotTests {

    static let html = "<html><body><p>Hello</p></body></html>"

    @Test
    func viewportScreenshot() async throws {
        let browser = try await MockBrowser(html: Self.html)
        let window = try await browser.startSession().window
        let image = try await window.screenshot()
        let size = try #require(image.representations.first)
        #expect(size.pixelsWide == MockBrowser.viewportScreenshotSize.width)
        #expect(size.pixelsHigh == MockBrowser.viewportScreenshotSize.height)
    }

    @Test
    func fullPageScreenshotUsesFirefoxEndpoint() async throws {
        let browser = try await MockBrowser(html: Self.html)
        let window = try await browser.startSession().window
        let image = try await window.screenshot(fullPage: true)
        let size = try #require(image.representations.first)
        #expect(size.pixelsWide == MockBrowser.fullPageScreenshotSize.width)
        #expect(size.pixelsHigh == MockBrowser.fullPageScreenshotSize.height)
    }

    @Test
    func undecodableScreenshotThrows() async throws {
        let browser = try await MockBrowser(html: Self.html)
        let window = try await browser.startSession().window

        browser.screenshotOverride = "not base64!"
        await #expect(throws: Session.SessionError.undecodableContent(expected: "a PNG image")) {
            try await window.screenshot()
        }

        browser.screenshotOverride = Data("not a png".utf8).base64EncodedString()
        await #expect(throws: Session.SessionError.undecodableContent(expected: "a PNG image")) {
            try await window.screenshot()
        }
    }

}
