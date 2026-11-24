//
//  Alert.swift
//  WebDriver
//
//  Created by Claude on 11/25/26.
//

import Foundation
import Essentials
import JSONParser


extension Session.Window {

    /// The user prompt, such as an `alert`, `confirm`, or `prompt` dialog, open in this window.
    ///
    /// Accessing it does not check whether a prompt is open. Its methods throw ``WebDriverError`` with ``WebDriverError/ErrorCode/no_such_alert`` when none is.
    ///
    /// > First Responder:
    /// > The methods of the alert switch the first responder to `self`.
    public var alert: Alert {
        Alert(window: self)
    }


    /// A user prompt, such as an `alert`, `confirm`, or `prompt` dialog.
    ///
    /// ```swift
    /// let message = try await window.alert.text
    /// try await window.alert.accept()
    /// ```
    ///
    /// ## See Also
    /// - [W3C WebDriver Specification – User Prompts](https://www.w3.org/TR/webdriver2/#user-prompts)
    public struct Alert: Sendable {

        let window: Session.Window

        /// The message of the prompt.
        public var text: String {
            get async throws {
                let parser = try await self.parser(.get, "text", context: .unavailable, invoker: "Alert.text")
                return try parser.decode(String.self, forKey: "value")
            }
        }

        /// Accepts the prompt, as if the user clicked OK.
        public func accept(fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function) async throws {
            try await self.parser(.post, "accept", context: SwiftContext(fileID: fileID, line: line, function: function))
        }

        /// Dismisses the prompt, as if the user clicked Cancel.
        ///
        /// For an `alert`, which only has OK, this is the same as ``accept(fileID:line:function:)``.
        public func dismiss(fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function) async throws {
            try await self.parser(.post, "dismiss", context: SwiftContext(fileID: fileID, line: line, function: function))
        }

        /// Types `text` into a `prompt` dialog.
        ///
        /// Call ``accept(fileID:line:function:)`` afterward to submit it.
        public func send(_ text: String, fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function) async throws {
            try await self.parser(.post, "text", json: ["text": text], context: SwiftContext(fileID: fileID, line: line, function: function))
        }

        @discardableResult
        private func parser(_ method: Session.HTTPMethod, _ partial: String, json: [String : Any]? = nil, context: SwiftContext, invoker: StaticString = #function) async throws -> JSONParser {
            try await self.window.becomeFirstResponder(context: context)

            let (data, _) = try await self.window.session.data(
                method,
                "/session/\(self.window.session.id)/alert/\(partial)",
                data: json.map { try JSONSerialization.data(withJSONObject: $0) },
                context: context,
                origin: .window(self.window),
                invoker: invoker
            )
            return try JSONParser(data: data)
        }

    }

}
