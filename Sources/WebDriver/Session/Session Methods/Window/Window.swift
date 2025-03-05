//
//  Window.swift
//  WebDriver
//
//  Created by Vaida on 3/5/25.
//

import Essentials


extension Session {
    
    /// A top-level browsing context.
    ///
    /// A WebDriver window represents a browser window or tab that can be controlled programmatically.
    ///
    /// In this implementation, a window encapsulates a `windowHandle`.
    ///
    /// Several properties and methods, including ``frame`` and ``close()``, will switch the first responder.
    public struct Window: Identifiable, Sendable {
        
        var session: Session
        
        /// The id that the backend uses to identify it.
        public let id: String
        
        /// The window type, either `tab` or `window`.
        public var type: WindowType?
        
        
        public enum WindowType: String, Sendable, Equatable {
            
            case tab
            
            case window
            
        }
    }
}


extension Session.Window {
    
    
    /// Makes the window the top level one.
    public func becomeFirstResponder() async throws {
        let _ = try await self.session.data(.post, "session/\(self.session.id)/window", json: ["handle" : self.id])
    }
    
    /// Closes the window.
    ///
    /// This is achieved by making the window first responder and closes the first responder.
    public func close() async throws {
        try await self.becomeFirstResponder()
        
        let _ = try await self.session.data(.delete, "session/\(self.session.id)/window", data: nil)
        // returns the closed window handle
    }
    
    
    
}
