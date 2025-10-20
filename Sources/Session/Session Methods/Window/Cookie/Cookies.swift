//
//  Cookie.swift
//  WebDriver
//
//  Created by Vaida on 3/7/25.
//

import Essentials


extension Session.Window {
    
    /// The cookie for the webpage associated with the ``window``.
    ///
    /// > First Responder:
    /// > Unless stated otherwise, the first responder is switched to the ``window`` associated with `self`.
    ///
    /// ## Topics
    /// ### Access Cookies
    /// - ``values``
    /// - ``subscript(_:)``
    ///
    /// ### Modify Cookies
    /// - ``append(_:)``
    /// - ``remove(_:)``
    /// - ``removeAll()``
    ///
    /// ### Structures
    /// - ``Cookie``
    public struct Cookies: Sendable {
        
        let window: Session.Window
        
        
        public var values: [Cookie] {
            get async throws {
                try await self.window.becomeFirstResponder()
                
                let (data, _) = try await self.window.session.data(.get, "/session/\(self.window.session.id)/cookie", data: nil, context: .unavailable, origin: .window(self.window), invoker: "Cookies.values")
                let parser = try JSONParser(data: data)
                
                return try parser.array("value").map(Cookie.init)
            }
        }
        
        public func append(_ cookie: Cookie, fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function) async throws {
            try await self.window.becomeFirstResponder(fileID: fileID, line: line, function: function)
            
            let _ = try await self.window.session.data(.post, "/session/\(self.window.session.id)/cookie", json: cookie.makeJSON(),
                                                       context: SwiftContext(fileID: fileID, line: line, function: function),
                                                       origin: .window(self.window),
                                                       invoker: #function)
        }
        
        public func remove(_ name: String, fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function) async throws {
            try await self.window.becomeFirstResponder(fileID: fileID, line: line, function: function)
            
            let _ = try await self.window.session.data(.delete, "/session/\(self.window.session.id)/cookie/\(name)", data: nil,
                                                       context: SwiftContext(fileID: fileID, line: line, function: function),
                                                       origin: .window(self.window),
                                                       invoker: #function)
        }
        
        public func removeAll(fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function) async throws {
            try await self.window.becomeFirstResponder(fileID: fileID, line: line, function: function)
            
            let _ = try await self.window.session.data(.delete, "/session/\(self.window.session.id)/cookie", data: nil,
                                                       context: SwiftContext(fileID: fileID, line: line, function: function),
                                                       origin: .window(self.window),
                                                       invoker: #function)
        }
        
        public subscript(name: String, fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function) -> Cookie {
            get async throws {
                try await self.window.becomeFirstResponder(fileID: fileID, line: line, function: function)
                
                let (data, _) = try await self.window.session.data(.get, "/session/\(self.window.session.id)/cookie/\(name)", data: nil,
                                                                   context: SwiftContext(fileID: fileID, line: line, function: function),
                                                                   origin: .window(self.window),
                                                                   invoker: #function)
                let parser = try JSONParser(data: data)
                
                return try Cookie(parser: parser.object("value"))
            }
        }
    }
    
    
    /// The cookie for the webpage associated with the window.
    public var cookies: Cookies {
        get async throws {
            Cookies(window: self)
        }
    }
    
}

