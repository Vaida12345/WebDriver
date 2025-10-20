//
//  Element.swift
//  WebDriver
//
//  Created by Vaida on 3/6/25.
//

import Foundation
import Essentials
import DetailedDescription


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
    public struct Element: Sendable { // Element should not be `CustomStringConvertible`
        
        let identity: Identity
        
        /// The element id.
        var id: String {
            self.identity.id
        }
        
        /// The window on which the element appears.
        let window: Session.Window
        
        
        @discardableResult
        internal func parser(_ method: Session.HTTPMethod, _ partial: String, json: [String : Any]? = nil, context: SwiftContext, invoker: StaticString = #function) async throws -> JSONParser? {
            try await self.window.becomeFirstResponder(fileID: context.fileID, line: context.line, function: context.function)
            
            let (data, _) = try await self.window.session.data(method, "/session/\(self.window.session.id)/element/\(self.id)/\(partial)", data: json.map { try JSONSerialization.data(withJSONObject: $0) }, context: context, origin: .element(self), invoker: invoker)
            return try? JSONParser(data: data)
        }
        
        
        init(parser: JSONParser, window: Session.Window, context: SwiftContext) throws {
            self.identity = Identity(id: try parser["element-6066-11e4-a52e-4f735466cecf"], creation: context)
            self.window = window
        }
    }
}


internal typealias Element = Session.Window.Element


extension Session.Window.Element: Equatable {
    
    public static func == (_ lhs: Session.Window.Element, _ rhs: Session.Window.Element) -> Bool {
        lhs.id == rhs.id
    }
    
}


extension Session.Window.Element: DetailedStringConvertible {
    
    public func detailedDescription(using descriptor: DetailedDescription.Descriptor<Session.Window.Element>) -> any DescriptionBlockProtocol {
        descriptor.container {
            descriptor.value("id", of: self.identity.id)
            descriptor.value("creation", of: self.identity.creation)
            descriptor.value("parent", of: self.window)
        }
    }
}
