//
//  Actions.swift
//  WebDriver
//
//  Created by Claude on 11/25/26.
//

import Essentials


extension Element {

    /// Moves the mouse over the center of the element.
    ///
    /// For other sequences, use ``Session/Window/perform(fileID:line:function:_:)``.
    public func hover(fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function) async throws {
        try await self.window.perform(fileID: fileID, line: line, function: function) {
            $0.move(to: self)
        }
    }

    /// Double-clicks the center of the element.
    public func doubleClick(fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function) async throws {
        try await self.window.perform(fileID: fileID, line: line, function: function) {
            $0.move(to: self)
            $0.pointerDown()
            $0.pointerUp()
            $0.pointerDown()
            $0.pointerUp()
        }
    }

    /// Right-clicks the center of the element, which usually opens its context menu.
    public func rightClick(fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function) async throws {
        try await self.window.perform(fileID: fileID, line: line, function: function) {
            $0.move(to: self)
            $0.pointerDown(button: .right)
            $0.pointerUp(button: .right)
        }
    }

    /// Drags the element onto `target`, holding the left mouse button.
    ///
    /// - Parameters:
    ///   - target: The element to drop onto.
    ///   - duration: How long the move from the element to `target` takes. Some pages only react to drags that take some time.
    public func drag(to target: Session.Window.Element, duration: Duration = .milliseconds(250), fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function) async throws {
        try await self.window.perform(fileID: fileID, line: line, function: function) {
            $0.move(to: self)
            $0.pointerDown()
            $0.move(to: target, duration: duration)
            $0.pointerUp()
        }
    }

    /// Presses `key` in the element, holding its modifiers.
    ///
    /// The element is focused first, as with ``write(_:terminator:fileID:line:function:)``.
    ///
    /// ```swift
    /// try await field.press(.init("a", modifiers: .command)) // Select all
    /// try await field.press(.tab)
    /// ```
    public func press(_ key: Session.Window.Key, fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function) async throws {
        // Element Send Keys holds modifier keys until the null key, `U+E000`, which releases them.
        let text = key.modifiers.keyValues.joined() + key.character + "\u{E000}"
        try await self.parser(.post, "value", json: ["text" : text], context: SwiftContext(fileID: fileID, line: line, function: function))
    }

}
