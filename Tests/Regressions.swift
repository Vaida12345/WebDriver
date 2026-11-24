//
//  Regressions.swift
//  WebDriver
//
//  Created by Claude on 11/25/26.
//
//  Regression tests for bugs found in code review: locator queries matching the wrong elements, properties loaded by their attribute names, cookies, stale elements while waiting, and errors sent with other status codes.
//

import Foundation
import Testing
import JSONParser
@testable
import WebDriver


extension Tag {
    @Tag static var regressions: Tag
}


@Suite(.tags(.regressions))
@MainActor
struct RegressionTests {

    static let html = """
    <html>
    <body>
        <a id="link" class="x">OK</a>
        <button id="button" class="x">OK</button>
        <span id="span">OK</span>
        <a id="docs" href="#">Docs</a>
        <div id="a"></div>
        <span id="b"></span>
        <label id="label" for="field" class="one two" tabindex="3">Name</label>
        <input id="field" disabled>
        <input id="enabled">
    </body>
    </html>
    """

    private static func ids(of elements: [Element]) async throws -> [String] {
        var ids: [String] = []
        for element in elements {
            ids.append(try await element.load(.id))
        }
        return ids
    }

    // MARK: - Locator queries

    @Test func tagDisjunctionANDChainedMatches() async throws {
        let browser = try await MockBrowser(html: Self.html)
        let window = try await browser.startSession().window

        let elements = try await window.findElements(where: { ($0.tag == "a" || $0.tag == "button") && $0.class == "x" && $0.text == "OK" })
        #expect(try await Self.ids(of: elements) == ["link", "button"])
    }

    @Test func sameTagANDLinkTextMatches() async throws {
        let browser = try await MockBrowser(html: Self.html)
        let window = try await browser.startSession().window

        let element = try await window.findElement(where: { $0.tag == "a" && $0.hrefText == "Docs" })
        #expect(try await element.load(.id) == "docs")
    }

    @Test func tagANDAttributeDisjunctionMatches() async throws {
        let browser = try await MockBrowser(html: Self.html)
        let window = try await browser.startSession().window

        let elements = try await window.findElements(where: { $0.tag == "div" && ($0.id == "a" || $0.id == "b") })
        #expect(try await Self.ids(of: elements) == ["a"])
    }

    // MARK: - Properties

    @Test func scriptSourceUsesPropertyNames() async throws {
        let browser = try await MockBrowser(html: Self.html)
        let window = try await browser.startSession().window

        let label = try await window.findElement(where: { $0.id == "label" })
        #expect(try await label.load(.className, at: .script) == "one two")
        #expect(try await label.load(.forAttribute, at: .script) == "field")
        #expect(try await label.load(.tabindex, at: .script) == "3")
    }

    @Test func nonStringPropertiesAreFormatted() async throws {
        let browser = try await MockBrowser(html: Self.html)
        let window = try await browser.startSession().window

        let field = try await window.findElement(where: { $0.id == "field" })
        #expect(try await field.load("disabled", at: .script) == "true")
        #expect(try await field.load("tabIndex", at: .script) == "0")
    }

    // MARK: - Cookies

    @Test func cookieExpiryIsAnInteger() {
        let cookie = Session.Window.Cookie(name: "name", value: "value", expiry: Date(timeIntervalSince1970: 1_700_000_000.75))
        let json = cookie.makeJSON()

        #expect(json["expiry"] as? Int == 1_700_000_000)
        #expect(json["domain"] == nil)
        #expect(json["path"] as? String == "/")
    }

    @Test func cookieWithoutSameSiteDecodes() throws {
        let data = Data(#"{"name":"name","value":"value","domain":"example.com","path":"/","secure":false,"httpOnly":false}"#.utf8)
        let cookie = try Session.Window.Cookie(parser: JSONParser(data: data))

        #expect(cookie.sameSite == nil)
        #expect(cookie.domain == "example.com")
    }

    // MARK: - Waiting

    @Test func waitingRetriesStaleElements() async throws {
        let browser = try await MockBrowser(html: Self.html)
        let window = try await browser.startSession().window
        browser.staleStateResponses = 1

        let element = try await window.wait(until: .elementEnabled, timeout: .seconds(5), where: { $0.id == "enabled" })
        #expect(try await element.load(.id) == "enabled")
        #expect(browser.staleStateResponses == 0)
    }

    // MARK: - Errors

    @Test func errorsWithOtherStatusCodesAreDecoded() async throws {
        let browser = try await MockBrowser(html: Self.html)
        let window = try await browser.startSession().window
        browser.scriptErrorOverride = (408, "script timeout")

        let error = await #expect(throws: WebDriverError.self) {
            try await window.execute("return 1")
        }
        #expect(error?.code == .script_timeout)
    }

}
