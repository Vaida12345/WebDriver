//
//  Alerts.swift
//  WebDriver
//
//  Created by Claude on 11/25/26.
//

import Testing
@testable
import WebDriver


extension Tag {
    @Tag static var alerts: Tag
}


@Suite(.tags(.alerts))
@MainActor
struct AlertTests {

    static let html = "<html><body><p>Page</p></body></html>"

    @Test func readsTheText() async throws {
        let browser = try await MockBrowser(html: Self.html)
        let window = try await browser.startSession().window
        browser.alertText = "Are you sure?"

        #expect(try await window.alert.text == "Are you sure?")
    }

    @Test func acceptAndDismiss() async throws {
        let browser = try await MockBrowser(html: Self.html)
        let window = try await browser.startSession().window

        browser.alertText = "First"
        try await window.alert.accept()
        #expect(browser.lastAlertAction == "accept")
        #expect(browser.alertText == nil)

        browser.alertText = "Second"
        try await window.alert.dismiss()
        #expect(browser.lastAlertAction == "dismiss")
    }

    @Test func sendsPromptText() async throws {
        let browser = try await MockBrowser(html: Self.html)
        let window = try await browser.startSession().window
        browser.alertText = "Your name?"

        try await window.alert.send("Ada")
        try await window.alert.accept()
        #expect(browser.promptText == "Ada")
    }

    @Test func missingAlertThrows() async throws {
        let browser = try await MockBrowser(html: Self.html)
        let window = try await browser.startSession().window

        let error = await #expect(throws: WebDriverError.self) {
            try await window.alert.accept()
        }
        #expect(error?.code == .no_such_alert)
    }

    @Test func waitForAlert() async throws {
        let browser = try await MockBrowser(html: Self.html)
        let window = try await browser.startSession().window

        await #expect(throws: Session.Window.WaitingTimeout.self) {
            try await window.wait(until: .alertPresent, timeout: .zero)
        }

        browser.alertText = "Done"
        try await window.wait(until: .alertPresent, timeout: .zero)
    }

}
