//
//  Actions.swift
//  WebDriver
//
//  Created by Claude on 11/25/26.
//
//  The mock browser records actions rather than performing them, so these tests check the JSON sent to the driver.
//

import Foundation
import Testing
@testable
import WebDriver


extension Tag {
    @Tag static var actions: Tag
}


@Suite(.tags(.actions))
@MainActor
struct ActionTests {

    typealias Key = Session.Window.Key

    static let html = """
    <html>
    <body>
        <div id="source">Source</div>
        <div id="target">Target</div>
        <input id="field">
    </body>
    </html>
    """

    private static let elementKey = "element-6066-11e4-a52e-4f735466cecf"

    /// The actions of the source with `id`, from the last Perform Actions request.
    private static func actions(of id: String, in browser: MockBrowser) -> [[String : Any]] {
        (browser.lastActions?.first(where: { $0["id"] as? String == id })?["actions"] as? [[String : Any]]) ?? []
    }

    private static func types(of id: String, in browser: MockBrowser) -> [String] {
        actions(of: id, in: browser).compactMap { $0["type"] as? String }
    }

    @Test func hover() async throws {
        let browser = try await MockBrowser(html: Self.html)
        let window = try await browser.startSession().window
        let source = try await window.findElement(where: { $0.id == "source" })

        try await source.hover()

        let move = try #require(Self.actions(of: "mouse", in: browser).first)
        #expect(move["type"] as? String == "pointerMove")
        #expect((move["origin"] as? [String : String])?[Self.elementKey] == source.id)
        #expect(browser.lastActions?.count == 1)
        #expect(browser.actionsReleased)
    }

    @Test func clicks() async throws {
        let browser = try await MockBrowser(html: Self.html)
        let window = try await browser.startSession().window
        let source = try await window.findElement(where: { $0.id == "source" })

        try await source.doubleClick()
        #expect(Self.types(of: "mouse", in: browser) == ["pointerMove", "pointerDown", "pointerUp", "pointerDown", "pointerUp"])

        try await source.rightClick()
        let buttons = Self.actions(of: "mouse", in: browser).compactMap { $0["button"] as? Int }
        #expect(buttons == [2, 2])
    }

    @Test func drag() async throws {
        let browser = try await MockBrowser(html: Self.html)
        let window = try await browser.startSession().window
        let source = try await window.findElement(where: { $0.id == "source" })
        let target = try await window.findElement(where: { $0.id == "target" })

        try await source.drag(to: target)

        let actions = Self.actions(of: "mouse", in: browser)
        #expect(actions.compactMap { $0["type"] as? String } == ["pointerMove", "pointerDown", "pointerMove", "pointerUp"])
        #expect((actions[2]["origin"] as? [String : String])?[Self.elementKey] == target.id)
        #expect(actions[2]["duration"] as? Int == 250)
    }

    /// Modifiers are pressed first, in order, and released last, in reverse order.
    @Test func pressWithModifiers() async throws {
        let browser = try await MockBrowser(html: Self.html)
        let window = try await browser.startSession().window

        try await window.perform {
            $0.press(Key("a", modifiers: [.command, .shift]))
        }

        let actions = Self.actions(of: "keyboard", in: browser)
        #expect(actions.compactMap { $0["type"] as? String } == ["keyDown", "keyDown", "keyDown", "keyUp", "keyUp", "keyUp"])
        #expect(actions.compactMap { $0["value"] as? String } == ["\u{E008}", "\u{E03D}", "a", "a", "\u{E03D}", "\u{E008}"])
    }

    @Test func elementPressSendsAChord() async throws {
        let browser = try await MockBrowser(html: Self.html)
        let window = try await browser.startSession().window
        let field = try await window.findElement(where: { $0.id == "field" })

        try await field.press(Key("a", modifiers: .command))
        #expect(browser.lastSentKeys == "\u{E03D}a\u{E000}")

        try await field.press(Key(.enter, modifiers: .shift))
        #expect(browser.lastSentKeys == "\u{E008}\u{E007}\u{E000}")
    }

    @Test func keyCombinesModifiers() {
        let key = Key(Key("a", modifiers: .command), modifiers: .shift)
        #expect(key.modifiers == [.command, .shift])
        #expect(key.character == "a")
        #expect(Key.enter.modifiers.isEmpty)
    }

    /// Each step is a tick: the other sources pause, so the sources stay in step.
    @Test func sourcesStayInStep() async throws {
        let browser = try await MockBrowser(html: Self.html)
        let window = try await browser.startSession().window

        try await window.perform {
            $0.keyDown(.shift)
            $0.move(by: CGPoint(x: 5, y: 0))
            $0.keyUp(.shift)
            $0.scroll(by: CGPoint(x: 0, y: 100))
        }

        #expect(Self.types(of: "keyboard", in: browser) == ["keyDown", "pause", "keyUp", "pause"])
        #expect(Self.types(of: "mouse", in: browser) == ["pause", "pointerMove", "pause", "pause"])
        #expect(Self.types(of: "wheel", in: browser) == ["pause", "pause", "pause", "scroll"])
        #expect(Self.actions(of: "wheel", in: browser).last?["deltaY"] as? Int == 100)
    }

    @Test func actionsAreReleasedAfterAFailure() async throws {
        let browser = try await MockBrowser(html: Self.html)
        let window = try await browser.startSession().window
        browser.actionsErrorOverride = "invalid argument"

        await #expect(throws: WebDriverError.self) {
            try await window.perform { $0.press(.enter) }
        }
        #expect(browser.actionsReleased)
    }

}
