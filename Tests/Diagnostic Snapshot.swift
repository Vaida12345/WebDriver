//
//  Diagnostic Snapshot.swift
//  WebDriver
//
//  Created by Claude on 11/25/26.
//

import Testing
@testable
import WebDriver


extension Tag {
    @Tag static var diagnosticSnapshot: Tag
}


@Suite(.tags(.diagnosticSnapshot))
@MainActor
struct DiagnosticSnapshotTests {

    static let longValue = String(repeating: "x", count: 300)

    static let html = """
    <html>
    <body>
        <div id="host"></div>
        <template id="own"><p>Template content</p></template>
        <script>
            const outer = document.getElementById("host").attachShadow({ mode: "open" });
            outer.innerHTML = '<style>button { color: red; }</style><!-- note --><button id="shadow1" title="\(longValue)">Shadow</button><div id="inner-host"></div>';
            outer.getElementById("inner-host").attachShadow({ mode: "open" }).innerHTML = '<b id="deep">Deep</b>';
        </script>
    </body>
    </html>
    """

    @Test func includesShadowContent() async throws {
        let browser = try await MockBrowser(html: Self.html)
        let window = try await browser.startSession().window

        let snapshot = try await window.diagnosticSnapshot

        #expect(snapshot.contains(#"<div id="host"><template shadowrootmode="open">"#))
        #expect(snapshot.contains(#"<button id="shadow1""#))
        #expect(snapshot.contains(#"<div id="inner-host"><template shadowrootmode="open"><b id="deep">Deep</b></template></div>"#))
    }

    @Test func trimsShadowContent() async throws {
        let browser = try await MockBrowser(html: Self.html)
        let window = try await browser.startSession().window

        let snapshot = try await window.diagnosticSnapshot

        #expect(snapshot.contains("<style>…("))
        #expect(!snapshot.contains("color: red"))
        #expect(!snapshot.contains("note"))
        #expect(!snapshot.contains(Self.longValue))
        #expect(snapshot.contains(String(repeating: "x", count: 80) + "…("))
    }

    @Test func pageTemplatesAreStillTrimmed() async throws {
        let browser = try await MockBrowser(html: Self.html)
        let window = try await browser.startSession().window

        let snapshot = try await window.diagnosticSnapshot

        #expect(snapshot.contains(#"<template id="own">…("#))
        #expect(!snapshot.contains("Template content"))
    }

    @Test func timeoutsCarryShadowContent() async throws {
        let browser = try await MockBrowser(html: Self.html)
        let window = try await browser.startSession().window

        let error = await #expect(throws: Session.Window.WaitingTimeout.self) {
            try await window.wait(until: .elementPresence, timeout: .zero, where: { $0.id == "deep" })
        }
        #expect(error?.details?.contains(#"<b id="deep">Deep</b>"#) == true)
    }

    @Test func pagesWithoutShadowRootsAreUnchanged() async throws {
        let browser = try await MockBrowser(html: #"<html><head></head><body><p id="a" class="b">Text</p></body></html>"#)
        let window = try await browser.startSession().window

        #expect(try await window.diagnosticSnapshot == #"<html><head></head><body><p id="a" class="b">Text</p></body></html>"#)
    }

}
