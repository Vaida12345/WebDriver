//
//  Interaction.swift
//  WebDriver
//
//  Created by Vaida on 3/7/25.
//


extension Element {
    
    /// Sends a click event to an element in the W3C WebDriver standard.
    ///
    /// This command simulates a user clicking on the specified element, triggering any associated event listeners.
    /// If the element is not interactable (e.g., invisible, disabled, or outside the viewport), an error will be returned.
    ///
    /// ## Behavior
    /// - If the element is a button, link, or interactive component, it will be activated.
    /// - If the element is a form control, it may receive focus before clicking.
    /// - If JavaScript event listeners are attached, they will be executed accordingly.
    ///
    /// - Note: Clicking an element may trigger JavaScript event handlers such as `onclick`.
    ///
    /// ## See Also
    /// - [W3C WebDriver Specification – Click](https://www.w3.org/TR/webdriver2/#element-click)
    public func click(fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function) async throws {
        try await self.parser(.post, "click", context: SwiftContext(fileID: fileID, line: line, function: function))
    }
    
    /// Sends a Javascript code execution that forces clicks.
    public func forceClick(fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function) async throws {
        let _ = try await self.window.execute("\(self).click();", fileID: fileID, line: line, function: function)
    }
    
    /// Clears the text content of an input or textarea element in the W3C WebDriver standard.
    ///
    /// This command removes any existing value from the specified element, simulating a user clearing the field manually.
    /// It applies only to elements that support text input, such as `<input>` and `<textarea>`.
    ///
    /// ## Behavior
    /// - If the element is an `<input>` or `<textarea>`, its value will be cleared.
    /// - If the element does not support text input, an `InvalidElementStateError` is returned.
    ///
    /// - Note: Clearing an input field may trigger JavaScript event handlers such as `oninput` or `onchange`.
    ///
    /// ## See Also
    /// - [W3C WebDriver Specification – Clear](https://www.w3.org/TR/webdriver2/#element-clear)
    public func clear(fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function) async throws {
        try await self.parser(.post, "clear", context: SwiftContext(fileID: fileID, line: line, function: function))
    }
    
    /// Writes the given `text` to the field.
    ///
    /// - Tip: This method can also be used to select an option of a picker.
    ///
    /// - Parameters:
    ///   - text: The text to input
    ///   - terminator: The default value is `\u{E007}`, which represents *enter*.
    public func write(_ text: String, terminator: String = "\u{E007}", fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function) async throws {
        let text = text + terminator
        try await self.parser(.post, "value", json: ["text" : text, "value" : Array(text).map({ String($0) })], context: SwiftContext(fileID: fileID, line: line, function: function))
    }
    
    /// Scrolls the element into view.
    public func scrollIntoView(fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function) async throws {
        let _ = try await self.window.execute("\(self).scrollIntoView();", fileID: fileID, line: line, function: function)
    }
    
}
