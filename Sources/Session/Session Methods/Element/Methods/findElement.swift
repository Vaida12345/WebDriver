//
//  findElement.swift
//  WebDriver
//
//  Created by Vaida on 3/7/25.
//

import Essentials
import JSONParser


extension Element {
    
    /// Find the element in the current element.
    public func findElement(where predicate: @Sendable (Session.Window.Element.LocatorProxy) -> any LocatorQuery, fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function) async throws -> Session.Window.Element {
        try await findElement(where: { predicate($0).makeQuery() }, fileID: fileID, line: line, function: function)
    }
    
    /// Find the element in the current element.
    public func findElement(where predicate: @Sendable (Session.Window.Element.LocatorProxy) -> Session.Window.Element.Query, fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function) async throws -> Session.Window.Element {
        try await self.window.becomeFirstResponder(fileID: fileID, line: line, function: function)
        
        let proxy = Element.LocatorProxy()
        let query = predicate(proxy)
        
        let (data, _) = try await self.window.session.data(
            .post,
            "/session/\(self.window.session.id)/element/\(self.id)/element",
            json: ["using": query.locator.rawValue, "value": query.value],
            context: SwiftContext(fileID: fileID, line: line, function: function),
            origin: .element(self),
            invoker: #function
        )
        
        return try Element(parser: JSONParser(data: data).decode(JSONParser.self, forKey: "value"), window: self.window, context: SwiftContext(fileID: fileID, line: line, function: function))
    }
    
    /// The direct children.
    public var children: [Session.Window.Element] {
        get async throws {
            let (data, _) = try await self.window.session.data(
                .post,
                "/session/\(self.window.session.id)/element/\(self.id)/elements",
                json: ["using": "xpath", "value": "./*"],
                context: .unavailable,
                origin: .element(self),
                invoker: #function
            )
            
            return try JSONParser(data: data).decode([JSONParser].self, forKey: "value").map({ try Element(parser: $0, window: self.window, context: SwiftContext(fileID: "<unavaiable>", line: -1, function: #function)) })
        }
    }
    
    /// Find the elements in the current element.
    public func findElements(where predicate: @Sendable (Session.Window.Element.LocatorProxy) -> any LocatorQuery, fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function) async throws -> [Session.Window.Element] {
        try await findElements(where: { predicate($0).makeQuery() }, fileID: fileID, line: line, function: function)
    }
    
    /// Find the elements in the current element.
    public func findElements(where predicate: @Sendable (Session.Window.Element.LocatorProxy) -> Session.Window.Element.Query, fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function) async throws -> [Session.Window.Element] {
        try await self.window.becomeFirstResponder(fileID: fileID, line: line, function: function)
        
        let proxy = Element.LocatorProxy()
        let query = predicate(proxy)
        
        let (data, _) = try await self.window.session.data(
            .post,
            "/session/\(self.window.session.id)/element/\(self.id)/elements",
            json: ["using": query.locator.rawValue, "value": query.value],
            context: SwiftContext(fileID: fileID, line: line, function: function),
            origin: .element(self),
            invoker: #function
        )
        
        return try JSONParser(data: data).decode([JSONParser].self, forKey: "value").map({ try Element(parser: $0, window: self.window, context: SwiftContext(fileID: fileID, line: line, function: function)) })
    }
    
}
