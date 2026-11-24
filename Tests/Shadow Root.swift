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

    // MARK: - Searching shadow content
    
    static let nestedHTML = """
    <html>
    <body>
        <button id="light1">Light</button>
        <div id="host"></div>
        <button id="light2">After</button>
        <script>
            const outer = document.getElementById("host").attachShadow({ mode: "open" });
            outer.innerHTML = '<button id="shadow1">Shadow</button><div id="inner-host"></div><a id="docs" href="#">Read   docs</a>';
            outer.getElementById("inner-host").attachShadow({ mode: "open" }).innerHTML = '<button id="deep">Deep</button>';
        </script>
    </body>
    </html>
    """
    
    private static func ids(of elements: [Session.Window.Element]) async throws -> [String] {
        var ids: [String] = []
        for element in elements {
            ids.append(try await element.load(.id))
        }
        return ids
    }
    
    /// Shadow content comes right after its host, before what follows the host.
    @Test func searchesInPageOrder() async throws {
        let browser = try await MockBrowser(html: Self.nestedHTML)
        let window = try await browser.startSession().window
        
        let buttons = try await window.findElements(where: { $0.tag == "button" }, includingShadowContent: true)
        #expect(try await Self.ids(of: buttons) == ["light1", "shadow1", "deep", "light2"])
    }
    
    @Test func findsInNestedShadowRoots() async throws {
        let browser = try await MockBrowser(html: Self.nestedHTML)
        let window = try await browser.startSession().window
        
        let deep = try await window.findElement(where: { $0.id == "deep" }, includingShadowContent: true)
        #expect(try await deep.load(.id) == "deep")
    }
    
    @Test func findsLinkText() async throws {
        let browser = try await MockBrowser(html: Self.nestedHTML)
        let window = try await browser.startSession().window
        
        #expect(try await window.findElement(where: { $0.hrefText == "Read docs" }, includingShadowContent: true).load(.id) == "docs")
        #expect(try await window.findElement(where: { $0.hrefText.contains("docs") }, includingShadowContent: true).load(.id) == "docs")
    }
    
    @Test func xpathQueriesAreUnsupported() async throws {
        let browser = try await MockBrowser(html: Self.nestedHTML)
        let window = try await browser.startSession().window
        
        await #expect(throws: Session.Window.ShadowContentSearchError.self) {
            try await window.findElement(where: { $0.text == "Deep" }, includingShadowContent: true)
        }
    }
    
    @Test func noMatchThrows() async throws {
        let browser = try await MockBrowser(html: Self.nestedHTML)
        let window = try await browser.startSession().window
        
        let error = await #expect(throws: WebDriverError.self) {
            try await window.findElement(where: { $0.tag == "table" }, includingShadowContent: true)
        }
        #expect(error?.code == .no_such_element)
        #expect(try await window.findElements(where: { $0.tag == "table" }, includingShadowContent: true).isEmpty)
    }
    
    @Test func elementScopedSearch() async throws {
        let browser = try await MockBrowser(html: Self.nestedHTML)
        let window = try await browser.startSession().window
        
        let host = try await window.findElement(where: { $0.id == "host" })
        let buttons = try await host.findElements(where: { $0.tag == "button" }, includingShadowContent: true)
        #expect(try await Self.ids(of: buttons) == ["shadow1", "deep"])
        #expect(try await host.findElement(where: { $0.tag == "button" }, includingShadowContent: true).load(.id) == "shadow1")
    }
    
    @Test func withoutShadowContent() async throws {
        let browser = try await MockBrowser(html: Self.nestedHTML)
        let window = try await browser.startSession().window
        
        let buttons = try await window.findElements(where: { $0.tag == "button" }, includingShadowContent: false)
        #expect(try await Self.ids(of: buttons) == ["light1", "light2"])
    }
    
}
