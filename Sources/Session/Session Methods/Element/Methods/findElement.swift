//
//  findElement.swift
//  WebDriver
//
//  Created by Vaida on 3/7/25.
//

import Essentials


extension Element {
    
    /// Find the element in the current element.
    public func findElement(where predicate: @Sendable (Session.Window.Element.LocatorProxy) -> any LocatorQuery) async throws -> Session.Window.Element {
        try await findElement(where: { predicate($0).makeQuery() })
    }
    
    /// Find the element in the current element.
    public func findElement(where predicate: @Sendable (Session.Window.Element.LocatorProxy) -> Session.Window.Element.Query) async throws -> Session.Window.Element {
        try await self.window.becomeFirstResponder()
        
        let proxy = Element.LocatorProxy()
        let query = predicate(proxy)
        
        let (data, _) = try await self.window.session.data(.post, "/session/\(self.window.session.id)/element/\(self.id)/element", json: ["using": query.locator.rawValue, "value": query.value])
        
        return try Element(parser: JSONParser(data: data).object("value"), window: self.window)
    }
    
    /// Find the elements in the current element.
    public func findElements(where predicate: @Sendable (Session.Window.Element.LocatorProxy) -> any LocatorQuery) async throws -> [Session.Window.Element] {
        try await findElements(where: { predicate($0).makeQuery() })
    }
    
    /// The direct children.
    public var children: [Session.Window.Element] {
        get async throws {
            let (data, _) = try await self.window.session.data(.post, "/session/\(self.window.session.id)/element/\(self.id)/element", json: ["using": "xpath", "value": "./*"])
            
            return try JSONParser(data: data).array("value").map({ try Element(parser: $0, window: self.window) })
        }
    }
    
    /// Find the elements in the current element.
    public func findElements(where predicate: @Sendable (Session.Window.Element.LocatorProxy) -> Session.Window.Element.Query) async throws -> [Session.Window.Element] {
        try await self.window.becomeFirstResponder()
        
        let proxy = Element.LocatorProxy()
        let query = predicate(proxy)
        
        let (data, _) = try await self.window.session.data(.post, "/session/\(self.window.session.id)/element/\(self.id)/element", json: ["using": query.locator.rawValue, "value": query.value])
        
        return try JSONParser(data: data).array("value").map({ try Element(parser: $0, window: self.window) })
    }
    
}
