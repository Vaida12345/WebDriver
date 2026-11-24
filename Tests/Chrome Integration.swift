//
//  Chrome Integration.swift
//  WebDriver
//
//  Created by Claude on 11/25/26.
//

import Foundation
import Testing
import FinderItem
@testable
import WebDriver


/// Runs against the installed `chromedriver` and Chrome, headless. Opt in with `CHROME_INTEGRATION=1`.
///
/// > Important:
/// > `chromedriver` must match Chrome's major version. Otherwise every test fails with ``WebDriverError/ErrorCode/session_not_created``.
@Suite(.serialized, .enabled(if: ProcessInfo.processInfo.environment["CHROME_INTEGRATION"] == "1" && WebDriver.Chrome.isAvailable))
struct ChromeIntegrationTests {
    
    static let page = URL(string: "data:text/html,<html><body style='height: 3000px'><p id='greeting'>Hello</p><div id='host'></div><script>document.getElementById('host').attachShadow({ mode: 'open' }).innerHTML = '<button id=\"inner\">Go</button>'</script></body></html>")!
    
    @Test(.timeLimit(.minutes(1)))
    func sessionRoundTrip() async throws {
        let session = try await WebDriver.Chrome().headless().windowSize(width: 800, height: 600).startSession()
        
        do {
            try await session.open(url: Self.page)
            let window = try await session.window
            
            let element = try await window.findElement(where: { $0.id == "greeting" })
            #expect(try await element.summary == #"<p id="greeting">Hello</p>"#)
            #expect(try await window.execute("return document.title.length + \(1)", as: Int.self) == 1)
            
            let viewport = try await window.screenshot()
            let fullPage = try await window.screenshot(fullPage: true)
            #expect(fullPage.size.height > viewport.size.height)
            
            let inner = try await window.findElement(where: { $0.id == "host" }).shadowRoot.findElement(where: { $0.id == "inner" })
            #expect(try await inner.load(.id) == "inner")
            #expect(try await window.findElement(where: { $0.id == "inner" }, includingShadowContent: true) == inner)
            
            _ = try await window.execute("setTimeout(() => alert('Hi'), 0)")
            try await window.wait(until: .alertPresent, timeout: .seconds(5))
            #expect(try await window.alert.text == "Hi")
            try await window.alert.accept()
        } catch {
            try? await session.close()
            throw error
        }
        try await session.close()
    }
    
    @Test(.timeLimit(.minutes(1)))
    func copiedProfileIsDeleted() async throws {
        let template = FinderItem.temporaryDirectory/"\(UUID()).template"
        try FileManager.default.createDirectory(atPath: template.path, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(atPath: template.path) }
        
        let session = try await WebDriver.Chrome().headless().profile(location: template).startSession()
        let copy = try #require((session.launcher.driver as? WebDriver.Chrome)?.chromeArg(prefix: "--user-data-dir"))
        #expect(copy.hasSuffix(".tempprofile") && FileManager.default.fileExists(atPath: copy))
        
        try await session.close()
        #expect(!FileManager.default.fileExists(atPath: copy))
        #expect(FileManager.default.fileExists(atPath: template.path))
    }
    
}
