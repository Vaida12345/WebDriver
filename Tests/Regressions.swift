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
        <div id="hidden" style="display: none">Hidden</div>
        <span id="role" role="alert">Role</span>
        <input id="file" type="file">
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

    @Test func errorsWithDifferentCodesAreNotEqual() async throws {
        let browser = try await MockBrowser(html: Self.html)
        let session = try await browser.startSession()

        let lhs = WebDriverError(code: .no_such_element, statusCode: 404, message: "message", context: .unavailable, origin: .session(session), invoker: #function)
        let rhs = WebDriverError(code: .stale_element_reference, statusCode: 404, message: "message", context: .unavailable, origin: .session(session), invoker: #function)

        #expect(lhs != rhs)
        #expect(lhs == lhs)
    }

    // MARK: - Zero timeout

    @Test func zeroTimeoutChecksOnce() async throws {
        let browser = try await MockBrowser(html: Self.html)
        let window = try await browser.startSession().window

        let element = try await window.wait(until: .elementPresence, timeout: .zero, where: { $0.id == "enabled" })
        #expect(try await element.load(.id) == "enabled")
    }

    // MARK: - Script interpolation

    @Test func interpolatedStringsArePassedAsArguments() async throws {
        let browser = try await MockBrowser(html: Self.html)
        let window = try await browser.startSession().window

        let text = #"a"b'c\d"#
        #expect(try await window.execute("return \(text)").decode(String.self, forKey: "value") == text)
        #expect(try await window.execute("return \(raw: "1 + 1") + \(3)").decode(Int.self, forKey: "value") == 5)
    }

    // MARK: - Waiting conditions
    
    @Test func waitForVisibleElement() async throws {
        let browser = try await MockBrowser(html: Self.html)
        let window = try await browser.startSession().window
        
        #expect(try await window.wait(until: .elementVisible, timeout: .zero, where: { $0.id == "role" }).load(.id) == "role")
        await #expect(throws: Session.Window.WaitingTimeout.self) {
            try await window.wait(until: .elementVisible, timeout: .zero, where: { $0.id == "hidden" })
        }
    }
    
    @Test func waitUntilAbsent() async throws {
        let browser = try await MockBrowser(html: Self.html)
        let window = try await browser.startSession().window
        
        try await window.waitUntilAbsent(timeout: .zero, where: { $0.id == "missing" })
        await #expect(throws: Session.Window.WaitingTimeout.self) {
            try await window.waitUntilAbsent(timeout: .zero, where: { $0.id == "hidden" })
        }
    }
    
    @Test func waitForURLAndTitle() async throws {
        let browser = try await MockBrowser(html: "<html><head><title>Checkout</title></head><body></body></html>")
        let window = try await browser.startSession().window
        
        try await window.wait(until: .titleContains("Check"), timeout: .zero)
        try await window.wait(until: .urlContains("about:"), timeout: .zero)
        await #expect(throws: Session.Window.WaitingTimeout.self) {
            try await window.wait(until: .titleContains("Receipt"), timeout: .zero)
        }
    }
    
    @Test func waitForCondition() async throws {
        let browser = try await MockBrowser(html: Self.html)
        let window = try await browser.startSession().window
        
        var calls = 0
        let start = ContinuousClock.now
        try await window.wait(timeout: .seconds(5), pollingInterval: .milliseconds(50)) {
            calls += 1
            return calls == 3
        }
        #expect(calls == 3)
        #expect(ContinuousClock.now - start >= .milliseconds(100))
        
        calls = 0
        await #expect(throws: Session.Window.WaitingTimeout.self) {
            try await window.wait(timeout: .zero) {
                calls += 1
                return false
            }
        }
        #expect(calls == 1)
    }
    
    // MARK: - Typed scripts, role, and upload
    
    @Test func typedExecute() async throws {
        let browser = try await MockBrowser(html: Self.html)
        let window = try await browser.startSession().window
        
        #expect(try await window.execute("return 1 + \(2)", as: Int.self) == 3)
        #expect(try await window.execute("return [\("a"), \("b")]", as: [String].self) == ["a", "b"])
    }
    
    @Test func role() async throws {
        let browser = try await MockBrowser(html: Self.html)
        let window = try await browser.startSession().window
        
        #expect(try await window.findElement(where: { $0.id == "role" }).role == "alert")
    }
    
    @Test func upload() async throws {
        let browser = try await MockBrowser(html: Self.html)
        let window = try await browser.startSession().window
        
        let input = try await window.findElement(where: { $0.id == "file" })
        try await input.upload(URL(filePath: "/tmp/my file.txt"))
        #expect(browser.lastSentKeys == "/tmp/my file.txt")
    }
    
}
