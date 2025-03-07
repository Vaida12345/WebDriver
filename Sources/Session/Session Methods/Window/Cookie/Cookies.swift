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
    public struct Cookies: Sendable {
        
        public let window: Session.Window
        
        
        public var values: [Cookie] {
            get async throws {
                try await self.window.becomeFirstResponder()
                
                let (data, _) = try await self.window.session.data(.get, "/session/\(self.window.session.id)/cookie", data: nil)
                let parser = try JSONParser(data: data)
                
                return try parser.array("value").map(Cookie.init)
            }
        }
        
        public func append(_ cookie: Cookie) async throws {
            try await self.window.becomeFirstResponder()
            
            let _ = try await self.window.session.data(.post, "/session/\(self.window.session.id)/cookie", json: cookie.makeJSON())
        }
        
        public func remove(_ name: String) async throws {
            try await self.window.becomeFirstResponder()
            
            let _ = try await self.window.session.data(.delete, "/session/\(self.window.session.id)/cookie/\(name)", data: nil)
        }
        
        public func removeAll() async throws {
            try await self.window.becomeFirstResponder()
            
            let _ = try await self.window.session.data(.delete, "/session/\(self.window.session.id)/cookie", data: nil)
        }
        
        public subscript(name: String) -> Cookie {
            get async throws {
                try await self.window.becomeFirstResponder()
                
                let (data, _) = try await self.window.session.data(.get, "/session/\(self.window.session.id)/cookie/\(name)", data: nil)
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

