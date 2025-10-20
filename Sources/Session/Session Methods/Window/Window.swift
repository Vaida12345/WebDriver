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
    ///
    /// ## Topics
    /// ### Swift Properties
    /// The properties introduced by this Swift implementation.
    /// - ``id``
    /// - ``type``
    /// - ``description``
    /// - ``becomeFirstResponder(fileID: fileID, line: line, function: function)``
    /// - ``close()``
    ///
    /// ### Cookie
    /// - ``cookies-swift.property``
    ///
    /// ### Document
    /// - ``pageSource``
    /// - ``execute(_:async:)``
    /// - ``execute(_:args:async:)``
    /// - ``screenshot()``
    /// - ``render(orientation:scale:includesBackground:width:height:scaleToFit:margin:)``
    ///
    /// ### Element
    /// - ``activeElement``
    /// - ``findElement(where:)-8rmlq``
    /// - ``findElements(where:)-794xe``
    /// - <doc:Locator>
    ///
    /// ### Position
    /// - ``frame``
    /// - ``setFrame(_:)``
    /// - ``setFrame(x:y:width:height:)``
    /// - ``maximize()``
    /// - ``minimize()``
    /// - ``fullscreen()``
    ///
    /// ### Structures
    /// - ``Cookies-swift.struct``
    /// - ``WindowType``
    /// - ``Margin``
    /// - ``PageOrientation``
    public struct Window: Identifiable, Sendable, CustomStringConvertible {
        
        var session: Session
        
        /// The id that the backend uses to identify it.
        public let identity: Identity
        
        public var id: String {
            self.identity.id
        }
        
        /// The window type, either `tab` or `window`.
        public var type: WindowType?
        
        
        public var description: String {
            var description = "Window<\(Swift.type(of: session.launcher.driver))"
            if let type {
                description.write(", \(type.rawValue)")
            }
            return description + ">" + "(id: \(self.identity.id), creation: \(self.identity.creation))"
        }
        
        
        public enum WindowType: String, Sendable, Equatable {
            
            case tab
            
            case window
            
        }
        
        init(session: Session, id: String, type: WindowType? = nil, context: SwiftContext) {
            self.session = session
            self.identity = Identity(id: id, creation: context)
            self.type = type
        }
    }
}


extension Session.Window: Equatable {
    public static func == (lhs: Session.Window, rhs: Session.Window) -> Bool {
        lhs.id == rhs.id
    }
}


extension Session.Window {
    
    
    /// Makes the window the top level browsing context.
    ///
    /// - Important: This does not necessarily mean the window is brought to front. This depends on the individual browser's implementations.
    public func becomeFirstResponder(fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function) async throws {
        let _ = try await self.session.data(.post, "session/\(self.session.id)/window", json: ["handle" : self.id],
                                            context: SwiftContext(fileID: fileID, line: line, function: function),
                                            origin: .window(self),
                                            invoker: #function)
    }
    
    /// Closes the window.
    ///
    /// This is achieved by making the window first responder and closes the first responder.
    public func close(fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function) async throws {
        try await self.becomeFirstResponder(fileID: fileID, line: line, function: function)
        
        let _ = try await self.session.data(.delete, "session/\(self.session.id)/window", data: nil,
                                            context: SwiftContext(fileID: fileID, line: line, function: function),
                                            origin: .window(self),
                                            invoker: #function)
        // returns the closed window handle
    }
    
    
    
}
