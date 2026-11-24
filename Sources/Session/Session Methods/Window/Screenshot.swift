//
//  Screenshot.swift
//  WebDriver
//
//  Created by Claude on 11/24/26.
//

import Foundation
import Essentials
import JSONParser
import NativeImage


extension Session.Window {

    /// Captures a screenshot of the page.
    ///
    /// - Parameters:
    ///   - fullPage: Whether to capture the whole page, rather than only the part visible in the viewport. Supported on Firefox and Chrome, through their own extensions; it fails with ``WebDriverError`` for other browsers.
    ///
    /// - Note: For a full-page screenshot, content outside the viewport that loads lazily may not have loaded yet. Very tall pages can exceed the browser's maximum image size, which fails with ``WebDriverError``.
    ///
    /// > First Responder:
    /// > The first responder is switched to `self`.
    public func screenshot(fullPage: Bool = false, fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function) async throws -> sending NativeImage {
        try await self.becomeFirstResponder(fileID: fileID, line: line, function: function)
        
        if fullPage, self.session.launcher.driver is WebDriver.Chrome {
            return try await self.chromeFullPageScreenshot(context: SwiftContext(fileID: fileID, line: line, function: function))
        }

        let endpoint = fullPage ? "moz/screenshot/full" : "screenshot"
        let (data, _) = try await self.session.data(
            .get,
            "session/\(self.session.id)/\(endpoint)",
            data: nil,
            context: SwiftContext(fileID: fileID, line: line, function: function),
            origin: .window(self),
            invoker: #function
        )
        return try decodeImage(from: JSONParser(data: data))
    }
    
    /// Captures the whole page through the Chrome DevTools Protocol, as chromedriver has no full-page screenshot command.
    private func chromeFullPageScreenshot(context: SwiftContext) async throws -> NativeImage {
        let (data, _) = try await self.session.data(
            .post,
            "session/\(self.session.id)/goog/cdp/execute",
            json: ["cmd": "Page.captureScreenshot", "params": ["format": "png", "captureBeyondViewport": true]],
            context: context,
            origin: .window(self),
            invoker: "screenshot(fullPage:fileID:line:function:)"
        )
        // The result is `{"value": {"data": "<base64>"}}`.
        return try decodeImage(from: JSONParser(data: data).decode(JSONParser.self, forKey: "value"), key: "data")
    }

}


/// Decodes the base64-encoded PNG image in `value`.
func decodeImage(from parser: JSONParser, key: String = "value") throws -> NativeImage {
    let data = try decodeBase64(from: parser, key: key, expected: "a PNG image")
    guard let image = NativeImage(data: data) else { throw Session.SessionError.undecodableContent(expected: "a PNG image") }
    return image
}

/// Decodes the base64-encoded data in `value`.
func decodeBase64(from parser: JSONParser, key: String = "value", expected: String) throws -> Data {
    let base64 = try parser.decode(String.self, forKey: key)
    guard let data = Data(base64Encoded: base64) else { throw Session.SessionError.undecodableContent(expected: expected) }
    return data
}
