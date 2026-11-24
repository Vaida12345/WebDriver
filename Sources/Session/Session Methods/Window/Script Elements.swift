//
//  Script Elements.swift
//  WebDriver
//
//  Created by Claude on 11/25/26.
//
//  Script execution that returns elements, for elements that the finders cannot reach.
//

import Essentials
import JSONParser


extension Session.Window {

    /// Executes the given command, which returns an element.
    ///
    /// Use it to reach elements that the finders cannot, such as those inside a shadow root:
    ///
    /// ```swift
    /// let buy = try await window.execute("""
    ///     return document.querySelector("my-card").shadowRoot.querySelector("button")
    ///     """, as: Session.Window.Element.self)
    /// try await buy.click()
    /// ```
    ///
    /// The element belongs to `self`, including the frame it is scoped to, if any.
    ///
    /// - Throws: ``WebDriverError`` with ``WebDriverError/ErrorCode/no_such_element`` when the script returns `null` or `undefined`, as ``findElement(where:fileID:line:function:)`` does when nothing matches.
    ///
    /// > First Responder:
    /// > The first responder is switched to `self`.
    public func execute(_ command: ScriptExecutionInterpolation, as type: Element.Type, async: Bool = false, fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function) async throws -> Element {
        try await self.execute(command.command, args: command.args, as: type, async: async, fileID: fileID, line: line, function: function)
    }

    /// Executes the given command, which returns an element or `null`.
    ///
    /// > First Responder:
    /// > The first responder is switched to `self`.
    public func execute(_ command: ScriptExecutionInterpolation, as type: Element?.Type, async: Bool = false, fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function) async throws -> Element? {
        try await self.execute(command.command, args: command.args, as: type, async: async, fileID: fileID, line: line, function: function)
    }

    /// Executes the given command, which returns an array of elements.
    ///
    /// > First Responder:
    /// > The first responder is switched to `self`.
    public func execute(_ command: ScriptExecutionInterpolation, as type: [Element].Type, async: Bool = false, fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function) async throws -> [Element] {
        try await self.execute(command.command, args: command.args, as: type, async: async, fileID: fileID, line: line, function: function)
    }


    /// Executes the given command with `args`, which returns an element.
    ///
    /// - Throws: ``WebDriverError`` with ``WebDriverError/ErrorCode/no_such_element`` when the script returns `null` or `undefined`.
    ///
    /// > First Responder:
    /// > The first responder is switched to `self`.
    public func execute(_ command: String, args: [Any], as type: Element.Type, async: Bool = false, fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function) async throws -> Element {
        let context = SwiftContext(fileID: fileID, line: line, function: function)
        guard let element = try await self.execute(command, args: args, as: Element?.self, async: async, fileID: fileID, line: line, function: function) else {
            throw WebDriverError(code: .no_such_element, statusCode: 404, message: "The script returned null instead of an element.", context: context, origin: .window(self), invoker: #function)
        }
        return element
    }

    /// Executes the given command with `args`, which returns an element or `null`.
    ///
    /// > First Responder:
    /// > The first responder is switched to `self`.
    public func execute(_ command: String, args: [Any], as type: Element?.Type, async: Bool = false, fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function) async throws -> Element? {
        let context = SwiftContext(fileID: fileID, line: line, function: function)
        let parser = try await self.execute(command, args: args, async: async, fileID: fileID, line: line, function: function)
        guard let value = try parser.decodeIfPresent(JSONParser.self, forKey: "value") else { return nil }
        return try Element(parser: value, window: self, context: context)
    }

    /// Executes the given command with `args`, which returns an array of elements.
    ///
    /// > First Responder:
    /// > The first responder is switched to `self`.
    public func execute(_ command: String, args: [Any], as type: [Element].Type, async: Bool = false, fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function) async throws -> [Element] {
        let context = SwiftContext(fileID: fileID, line: line, function: function)
        let parser = try await self.execute(command, args: args, async: async, fileID: fileID, line: line, function: function)
        return try parser.decode([JSONParser].self, forKey: "value").map { try Element(parser: $0, window: self, context: context) }
    }

}
