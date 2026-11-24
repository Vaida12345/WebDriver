//
//  Frames.swift
//  WebDriver
//
//  Created by Claude on 11/25/26.
//

import Testing
@testable
import WebDriver


extension Tag {
    @Tag static var frames: Tag
}


@Suite(.tags(.frames))
@MainActor
struct FrameTests {

    static let html = """
    <html>
    <body>
        <p id="top">Top</p>
        <iframe id="outer" srcdoc="<title>Outer</title><p id='inside'>Outer</p><iframe id='inner' srcdoc='<b id=deep>Deep</b>'></iframe>"></iframe>
    </body>
    </html>
    """

    @Test func findsInsideAFrame() async throws {
        let browser = try await MockBrowser(html: Self.html)
        let window = try await browser.startSession().window

        let outer = window.content(of: try await window.findElement(where: { $0.id == "outer" }))
        let inside = try await outer.findElement(where: { $0.id == "inside" })

        #expect(try await inside.load(.id) == "inside")
        #expect(inside.window.framePath.count == 1)
    }

    @Test func findsInsideNestedFrames() async throws {
        let browser = try await MockBrowser(html: Self.html)
        let window = try await browser.startSession().window

        let outer = window.content(of: try await window.findElement(where: { $0.id == "outer" }))
        let inner = outer.content(of: try await outer.findElement(where: { $0.id == "inner" }))
        let deep = try await inner.findElement(where: { $0.id == "deep" })

        #expect(try await deep.load(.id) == "deep")
        #expect(inner.framePath.count == 2)
    }

    @Test func scriptsRunInTheFrame() async throws {
        let browser = try await MockBrowser(html: Self.html)
        let window = try await browser.startSession().window

        let outer = window.content(of: try await window.findElement(where: { $0.id == "outer" }))
        #expect(try await outer.execute("return document.title", as: String.self) == "Outer")
    }

    /// The window itself stays scoped to the top-level document, even after a frame was used.
    @Test func topLevelIsRestored() async throws {
        let browser = try await MockBrowser(html: Self.html)
        let window = try await browser.startSession().window

        let outer = window.content(of: try await window.findElement(where: { $0.id == "outer" }))
        _ = try await outer.findElement(where: { $0.id == "inside" })

        #expect(try await window.findElement(where: { $0.id == "top" }).load(.id) == "top")
        let error = await #expect(throws: WebDriverError.self) {
            try await window.findElement(where: { $0.id == "inside" })
        }
        #expect(error?.code == .no_such_element)
        #expect(window != outer)
    }

}
