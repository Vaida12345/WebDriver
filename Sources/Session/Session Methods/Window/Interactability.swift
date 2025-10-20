//
//  Interactability.swift
//  WebDriver
//
//  Created by Vaida on 3/7/25.
//

import Foundation
import Essentials


extension Session.Window {
    
    /// Find the element in the document element of the window.
    ///
    /// > First Responder:
    /// > The first responder is switched to `self`.
    public func findElement(where predicate: @Sendable (Element.LocatorProxy) -> any LocatorQuery, fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function) async throws -> Element {
        try await findElement(where: { predicate($0).makeQuery() }, fileID: fileID, line: line, function: function)
    }
    
    /// Find the element in the document element of the window.
    ///
    /// > First Responder:
    /// > The first responder is switched to `self`.
    public func findElement(where predicate: @Sendable (Element.LocatorProxy) -> Element.Query, fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function) async throws -> Element {
        try await self.becomeFirstResponder(fileID: fileID, line: line, function: function)
        
        let proxy = Element.LocatorProxy()
        let query = predicate(proxy)
        
        let (data, _) = try await self.session.data(.post, "/session/\(self.session.id)/element", json: ["using": query.locator.rawValue, "value": query.value],
                                                    context: SwiftContext(fileID: fileID, line: line, function: function),
                                                    origin: .window(self),
                                                    invoker: #function)
        
        return try Element(parser: JSONParser(data: data).object("value"), window: self, context: SwiftContext(fileID: fileID, line: line, function: function))
    }
    
    /// Find the elements in the document element of the window.
    ///
    /// > First Responder:
    /// > The first responder is switched to `self`.
    public func findElements(where predicate: @Sendable (Element.LocatorProxy) -> any LocatorQuery, fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function) async throws -> [Element] {
        try await findElements(where: { predicate($0).makeQuery() }, fileID: fileID, line: line, function: function)
    }
    
    /// Find the elements in the document element of the window.
    ///
    /// > First Responder:
    /// > The first responder is switched to `self`.
    public func findElements(where predicate: @Sendable (Element.LocatorProxy) -> Element.Query, fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function) async throws -> [Element] {
        try await self.becomeFirstResponder(fileID: fileID, line: line, function: function)
        
        let proxy = Element.LocatorProxy()
        let query = predicate(proxy)
        
        let (data, _) = try await self.session.data(.post, "/session/\(self.session.id)/elements", json: ["using": query.locator.rawValue, "value": query.value],
                                                    context: SwiftContext(fileID: fileID, line: line, function: function),
                                                    origin: .window(self),
                                                    invoker: #function)
        
        return try JSONParser(data: data).array("value").map({ try Element(parser: $0, window: self, context: SwiftContext(fileID: fileID, line: line, function: function)) })
    }
    
    
    /// The active element is the element that currently has focus in the browser.
    ///
    /// An element is active when:
    /// - A user clicks on an input field, button, or link.
    /// - An element gains focus via keyboard navigation (Tab key).
    /// - Focus is set programmatically using JavaScript (`element.focus()`).
    ///
    /// > First Responder:
    /// > The first responder is switched to `self`.
    public var activeElement: Element {
        get async throws {
            try await self.becomeFirstResponder()
            
            let (data, _) = try await self.session.data(.get, "/session/\(self.session.id)/element/active", data: nil, context: .unavailable, origin: .window(self), invoker: "Session.Window.activeElement")
            
            return try Element(parser: JSONParser(data: data).object("value"), window: self, context: SwiftContext(fileID: "<unavailable>", line: -1, function: #function))
        }
    }
    
}
