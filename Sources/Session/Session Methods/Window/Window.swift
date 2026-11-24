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
    /// - ``diagnosticSnapshot``
    /// - ``execute(_:async:)``
    /// - ``execute(_:args:async:)``
    /// - ``screenshot(fullPage:fileID:line:function:)``
    /// - ``render(orientation:scale:includesBackground:width:height:scaleToFit:margin:)``
    ///
    /// ### Frames
    /// - ``content(of:)``
    ///
    /// ### Alerts
    /// - ``alert``
    /// - ``Alert``
    ///
    /// ### Actions
    /// - ``perform(fileID:line:function:_:)``
    /// - ``ActionBuilder``
    /// - ``Key``
    ///
    /// ### Waiting
    /// - ``wait(until:timeout:pollingInterval:where:fileID:line:function:)``
    /// - ``wait(until:timeout:pollingInterval:)``
    /// - ``wait(timeout:pollingInterval:isolation:until:)``
    /// - ``waitUntilAbsent(timeout:pollingInterval:where:fileID:line:function:)``
    /// - ``WaitingTimeout``
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
    /// - ``ShadowRoot``
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
        
        /// The frame elements, outermost first, whose document this window value is scoped to. It is empty for the top-level document.
        ///
        /// Use ``content(of:)`` to scope a window to a frame.
        internal var framePath: [Element] = []
        
        
        public var description: String {
            var description = "Window<\(Swift.type(of: session.launcher.driver))"
            if let type {
                description.write(", \(type.rawValue)")
            }
            if !framePath.isEmpty {
                description.write(", frame depth \(framePath.count)")
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
        lhs.id == rhs.id && lhs.framePath == rhs.framePath
    }
}


extension Session.Window {
    
    
    /// Makes the window the top level browsing context.
    ///
    /// - Important: This does not necessarily mean the window is brought to front. This depends on the individual browser's implementations.
    public func becomeFirstResponder(fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function) async throws {
        try await self.becomeFirstResponder(context: SwiftContext(fileID: fileID, line: line, function: function))
    }
    
    /// Makes the window the top level browsing context, reporting errors at `context`.
    ///
    /// Getters, which cannot take the caller's location, pass ``SwiftContext/unavailable``, so that errors do not point inside the package.
    func becomeFirstResponder(context: SwiftContext) async throws {
        // Switching to the window also switches to its top-level document.
        let _ = try await self.session.data(.post, "session/\(self.session.id)/window", json: ["handle" : self.id],
                                            context: context,
                                            origin: .window(self),
                                            invoker: "becomeFirstResponder(fileID:line:function:)")
        
        for frame in self.framePath {
            let _ = try await self.session.data(.post, "session/\(self.session.id)/frame", json: ["id" : ["element-6066-11e4-a52e-4f735466cecf" : frame.id]],
                                                context: context,
                                                origin: .element(frame),
                                                invoker: "becomeFirstResponder(fileID:line:function:)")
        }
    }
    
    /// The document inside the given `<iframe>` or `<frame>` element.
    ///
    /// The returned window value is scoped to the frame: elements found and scripts executed through it run in the frame's document. Frames can be nested by calling this on a window that is already scoped to a frame.
    ///
    /// ```swift
    /// let frame = try await window.findElement(where: { $0.tag == "iframe" })
    /// let content = window.content(of: frame)
    /// let button = try await content.findElement(where: { $0.text == "Pay" })
    /// ```
    ///
    /// - Parameter frame: A frame element. The result is based on the window in which `frame` was found.
    public func content(of frame: Element) -> Session.Window {
        var window = frame.window
        window.framePath.append(frame)
        return window
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
