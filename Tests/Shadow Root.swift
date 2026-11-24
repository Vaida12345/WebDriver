//
//  Shadow Root.swift
//  WebDriver
//
//  Created by Claude on 11/25/26.
//

import Testing
@testable
import WebDriver


extension Tag {
    @Tag static var shadowRoot: Tag
}


@Suite(.tags(.shadowRoot))
@MainActor
struct ShadowRootTests {

    static let html = """
    <html>
    <body>
        <div id="host"></div>
        <div id="plain"></div>
        <script>
            document.getElementById("host").attachShadow({ mode: "open" }).innerHTML = '<button id="inner">Go</button><button id="other">Stop</button>';
        </script>
    </body>
    </html>
    """

    @Test func findsInsideTheShadowRoot() async throws {
        let browser = try await MockBrowser(html: Self.html)
        let window = try await browser.startSession().window

        let host = try await window.findElement(where: { $0.id == "host" })
        let root = try await host.shadowRoot

        #expect(try await root.findElement(where: { $0.id == "inner" }).load(.id) == "inner")
        #expect(try await root.findElements(where: { $0.tag == "button" }).count == 2)
        #expect(root.host == host)
    }

    @Test func documentDoesNotSeeShadowContent() async throws {
        let browser = try await MockBrowser(html: Self.html)
        let window = try await browser.startSession().window

        let error = await #expect(throws: WebDriverError.self) {
            try await window.findElement(where: { $0.id == "inner" })
        }
        #expect(error?.code == .no_such_element)
    }

    @Test func missingShadowRootThrows() async throws {
        let browser = try await MockBrowser(html: Self.html)
        let window = try await browser.startSession().window

        let plain = try await window.findElement(where: { $0.id == "plain" })
        let error = await #expect(throws: WebDriverError.self) {
            try await plain.shadowRoot
        }
        #expect(error?.code == .no_such_shadow_root)
    }

}
