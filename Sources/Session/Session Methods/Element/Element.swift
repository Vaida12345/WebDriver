//
//  Element.swift
//  WebDriver
//
//  Created by Vaida on 3/6/25.
//

import Foundation
import Essentials


extension Session.Window {
    
    /// An UI Element
    ///
    /// > First Responder:
    /// > Unless stated otherwise, the first responder is switched to the window in which `self` locates.
    ///
    /// ## Topics
    /// ### Locators
    /// ### Locators
    /// - ``findElement(where:)-8rmlq``
    /// - ``findElements(where:)-794xe``
    /// - <doc:Locator>
    ///
    /// ### State
    /// - ``isSelected``
    /// - ``isEnabled``
    ///
    /// ### Attribute
    /// - ``tag``
    /// - ``text``
    /// - ``label``
    /// - ``frame``
    /// - ``load(_:at:)-43sms``
    ///
    /// ### Interaction
    /// - ``click()``
    /// - ``write(_:terminator:)``
    /// - ``clear()``
    ///
    /// ### Render
    /// - ``screenshot()``
    ///
    /// ### Structures
    /// - ``LoadSource``
    /// - ``LoadableAttribute``
    /// - ``Locator``
    public struct Element: Sendable { // Element should not be `CustomStringConvertable`
        
        /// The element id.
        let id: String
        
        /// The window on which the element appears.
        let window: Session.Window
        
        
        @discardableResult
        internal func parser(_ method: Session.HTTPMethod, _ partial: String, json: [String : Any]? = nil) async throws -> JSONParser? {
            try await self.window.becomeFirstResponder()
            
            let (data, _) = try await self.window.session.data(method, "/session/\(self.window.session.id)/element/\(self.id)/\(partial)", data: json.map { try JSONSerialization.data(withJSONObject: $0) })
            return try? JSONParser(data: data)
        }
        
        
        init(parser: JSONParser, window: Session.Window) throws {
            self.id = try parser["element-6066-11e4-a52e-4f735466cecf"]
            self.window = window
        }
        
    }
    
}


internal typealias Element = Session.Window.Element
