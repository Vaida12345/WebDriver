//
//  Script Elements.swift
//  WebDriver
//
//  Created by Claude on 11/25/26.
//

import Testing
@testable
import WebDriver


extension Tag {
    @Tag static var scriptElements: Tag
}


@Suite(.tags(.scriptElements))
@MainActor
struct ScriptElementTests {

    typealias Element = Session.Window.Element

    static let html = """
    <html>
    <body>
        <p id="a">A</p>
        <p id="b">B</p>
        <iframe id="frame" srcdoc="<b id='inside'>Inside</b>"></iframe>
    </body>
    </html>
    """

    @Test func returnsAnElement() async throws {
        let browser = try await MockBrowser(html: Self.html)
        let window = try await browser.startSession().window

        let element = try await window.execute("return document.getElementById(\("b"))", as: Element.self)
        #expect(try await element.load(.id) == "b")
        #expect(element == (try await window.findElement(where: { $0.id == "b" })))
    }

    @Test func returnsElementsInOrder() async throws {
        let browser = try await MockBrowser(html: Self.html)
        let window = try await browser.startSession().window

        let elements = try await window.execute("return [...document.querySelectorAll('p')].reverse()", as: [Element].self)
        var ids: [String] = []
        for element in elements {
            ids.append(try await element.load(.id))
        }
        #expect(ids == ["b", "a"])
    }

    @Test func nullResult() async throws {
        let browser = try await MockBrowser(html: Self.html)
        let window = try await browser.startSession().window

        #expect(try await window.execute("return null", as: Element?.self) == nil)
        #expect(try await window.execute("return document.getElementById('a')", as: Element?.self) != nil)

        let error = await #expect(throws: WebDriverError.self) {
            try await window.execute("return document.getElementById('missing')", as: Element.self)
        }
        #expect(error?.code == .no_such_element)
    }

    @Test func keepsTheFrame() async throws {
        let browser = try await MockBrowser(html: Self.html)
        let window = try await browser.startSession().window

        let content = window.content(of: try await window.findElement(where: { $0.id == "frame" }))
        let element = try await content.execute("return document.getElementById('inside')", as: Element.self)

        #expect(element.window.framePath.count == 1)
        #expect(try await element.load(.id) == "inside")
    }

}
