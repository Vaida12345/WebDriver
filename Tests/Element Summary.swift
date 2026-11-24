//
//  Element Summary.swift
//  WebDriver
//
//  Created by Claude on 11/24/26.
//

import Testing
@testable
import WebDriver


extension Tag {
    @Tag static var summary: Tag
}


@Suite(.tags(.summary))
@MainActor
struct ElementSummaryTests {

    static let longURL = "https://example.com/" + String(repeating: "x", count: 200)

    static let html = """
    <html>
    <body>
        <main id="main">
            <a id="link" class="primary" href="\(longURL)">
                Learn
                more
            </a>
            <p id="nested">Some <b>bold</b> text</p>
            <input id="field" type="text" value="hello">
            <span id="escaped">a &lt; b</span>
            <div id="empty"></div>
        </main>
        <p id="long">\(String(repeating: "word ", count: 40))</p>
    </body>
    </html>
    """

    @Test func tagWithCollapsedText() async throws {
        let browser = try await MockBrowser(html: Self.html)
        let window = try await browser.startSession().window

        let link = try await window.findElement(where: { $0.id == "link" })
        let href = String(Self.longURL.prefix(80)) + "…"
        #expect(try await link.summary == #"<a id="link" class="primary" href="\#(href)">Learn more</a>"#)
    }

    @Test func childElementsAreFlattened() async throws {
        let browser = try await MockBrowser(html: Self.html)
        let window = try await browser.startSession().window

        #expect(try await window.findElement(where: { $0.id == "nested" }).summary == #"<p id="nested">Some bold text</p>"#)

        #expect(try await window.findElement(where: { $0.id == "main" }).summary == #"<main id="main">Learn more Some bold text a &lt; b</main>"#)
    }
    
    @Test func longTextIsShortened() async throws {
        let browser = try await MockBrowser(html: Self.html)
        let window = try await browser.startSession().window
        
        let text = String(String(repeating: "word ", count: 40).prefix(80)) + "…"
        #expect(try await window.findElement(where: { $0.id == "long" }).summary == #"<p id="long">\#(text)</p>"#)
    }

    @Test func voidEscapedAndEmptyElements() async throws {
        let browser = try await MockBrowser(html: Self.html)
        let window = try await browser.startSession().window

        #expect(try await window.findElement(where: { $0.id == "field" }).summary == #"<input id="field" type="text" value="hello">"#)
        #expect(try await window.findElement(where: { $0.id == "escaped" }).summary == #"<span id="escaped">a &lt; b</span>"#)
        #expect(try await window.findElement(where: { $0.id == "empty" }).summary == #"<div id="empty"></div>"#)
    }

    @Test func elementErrorCarriesSummary() async throws {
        let browser = try await MockBrowser(html: Self.html)
        let window = try await browser.startSession().window

        let nested = try await window.findElement(where: { $0.id == "nested" })
        let error = try #require(await #expect(throws: WebDriverError.self) {
            try await nested.findElement(where: { $0.id == "does-not-exist" })
        })
        #expect(error.code == .no_such_element)
        #expect(error.elementSummary == #"<p id="nested">Some bold text</p>"#)
        #expect(error.description.contains(#"element: <p id="nested">Some bold text</p>"#))
    }

    @Test func staleElementHasNoSummary() async throws {
        let browser = try await MockBrowser(html: Self.html)
        let window = try await browser.startSession().window

        let nested = try await window.findElement(where: { $0.id == "nested" })
        _ = try await window.execute("arguments[0].remove()", args: [["element-6066-11e4-a52e-4f735466cecf": nested.id]])

        let error = try #require(await #expect(throws: WebDriverError.self) {
            try await nested.summary
        })
        #expect(error.code == .stale_element_reference)
        #expect(error.elementSummary == nil)
    }

    @Test func windowErrorHasNoSummary() async throws {
        let browser = try await MockBrowser(html: Self.html)
        let window = try await browser.startSession().window

        let error = try #require(await #expect(throws: WebDriverError.self) {
            try await window.findElement(where: { $0.id == "does-not-exist" })
        })
        #expect(error.code == .no_such_element)
        #expect(error.elementSummary == nil)
    }

}
