//
//  Window Position.swift
//  WebDriver
//
//  Created by Vaida on 3/5/25.
//

import Essentials
import CoreGraphics
import JSONParser


extension Session.Window {
    
    /// The window rect.
    ///
    /// > First Responder:
    /// > The first responder is switched to `self`.
    ///
    /// ## Coordinate System
    ///
    /// The coordinate systems for WebDriver window rect and `CGRect` are essentially the same in terms of their basic structure and how they define the window's position and size.
    ///
    /// - Origin (0, 0): Both use the top-left corner of the screen as the origin.
    ///     - WebDriver: The top-left corner of the screen is (0, 0) in its coordinate system.
    ///     - `CGRect`: Similarly, the top-left corner of the screen or window is also (0, 0) in its coordinate system.
    /// - Position and Size:
    ///     - Both systems define a bounding box for the window using:
    ///         - `x`: The horizontal distance from the left edge of the screen or parent container.
    ///         - `y`: The vertical distance from the top edge of the screen or parent container.
    ///         - `width`: The width of the window or view.
    ///         - `height`: The height of the window or view.
    /// - Coordinate Meaning:
    ///     - Both systems represent a window's position relative to the screen or parent container, starting from the top-left corner.
    public var frame: CGRect {
        get async throws {
            try await self.becomeFirstResponder()
            
            let (data, _) = try await self.session.data(.get, "session/\(self.session.id)/window/rect", data: nil, context: .unavailable, origin: .window(self), invoker: #function)
            let parser = try JSONParser(data: data).decode(JSONParser.self, forKey: "value")
            
            return try CGRect(x: parser.decode(Double.self, forKey: "x"),
                              y: parser.decode(Double.self, forKey: "y"),
                              width: parser.decode(Double.self, forKey: "width"),
                              height: parser.decode(Double.self, forKey: "height"))
        }
    }
    
    /// Set the window rect.
    ///
    /// > First Responder:
    /// > The first responder is switched to `self`.
    ///
    /// The coordinate systems for WebDriver window rect and `CGRect` are essentially the same in terms of their basic structure and how they define the window's position and size. See ``frame`` for more information.
    ///
    /// - Returns: The frame for the first responder (ie, `self`).
    @discardableResult
    public func setFrame(_ frame: CGRect, fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function) async throws -> CGRect {
        try await self.setFrame(x: frame.origin.x, y: frame.origin.y, width: frame.width, height: frame.height, fileID: fileID, line: line, function: function)
    }
    
    /// Set the window rect.
    ///
    /// > First Responder:
    /// > The first responder is switched to `self`.
    ///
    /// The coordinate systems for WebDriver window rect and `CGRect` are essentially the same in terms of their basic structure and how they define the window's position and size. See ``frame`` for more information.
    ///
    /// - Returns: The frame for the first responder (ie, `self`).
    @discardableResult
    public func setFrame(x: CGFloat?, y: CGFloat?, width: CGFloat?, height: CGFloat?, fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function) async throws -> CGRect {
        try await self.becomeFirstResponder(fileID: fileID, line: line, function: function)
        
        var parameters: [String: Any] = [:]
        
        if let x = x { parameters["x"] = x }
        if let y = y { parameters["y"] = y }
        if let width = width { parameters["width"] = width }
        if let height = height { parameters["height"] = height }
        
        let (data, _) = try await self.session.data(.post, "session/\(self.session.id)/window/rect", json: parameters,
                                                    context: SwiftContext(fileID: fileID, line: line, function: function),
                                                    origin: .window(self),
                                                    invoker: #function)
        let parser = try JSONParser(data: data).decode(JSONParser.self, forKey: "value")
        
        return try CGRect(x: parser.decode(Double.self, forKey: "x"),
                          y: parser.decode(Double.self, forKey: "y"),
                          width: parser.decode(Double.self, forKey: "width"),
                          height: parser.decode(Double.self, forKey: "height"))
    }
    
    
    /// Increases the window to the maximum available size without going full-screen.
    ///
    /// > First Responder:
    /// > The first responder is switched to `self`.
    ///
    /// The coordinate systems for WebDriver window rect and `CGRect` are essentially the same in terms of their basic structure and how they define the window's position and size. See ``frame`` for more information.
    ///
    /// - Returns: The frame for the first responder (ie, `self`).
    @discardableResult
    public func maximize(fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function) async throws -> CGRect {
        try await self.becomeFirstResponder(fileID: fileID, line: line, function: function)
        
        let (data, _) = try await self.session.data(.post, "session/\(self.session.id)/window/maximize", data: nil,
                                                    context: SwiftContext(fileID: fileID, line: line, function: function),
                                                    origin: .window(self),
                                                    invoker: #function)
        let parser = try JSONParser(data: data).decode(JSONParser.self, forKey: "value")
        
        return try CGRect(x: parser.decode(Double.self, forKey: "x"),
                          y: parser.decode(Double.self, forKey: "y"),
                          width: parser.decode(Double.self, forKey: "width"),
                          height: parser.decode(Double.self, forKey: "height"))
    }
    
    /// Hides the window in the system tray.
    ///
    /// > First Responder:
    /// > The first responder is switched to `self`.
    ///
    /// The coordinate systems for WebDriver window rect and `CGRect` are essentially the same in terms of their basic structure and how they define the window's position and size. See ``frame`` for more information.
    ///
    /// - Returns: The frame for the first responder (ie, `self`).
    @discardableResult
    public func minimize(fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function) async throws -> CGRect {
        try await self.becomeFirstResponder(fileID: fileID, line: line, function: function)
        
        let (data, _) = try await self.session.data(.post, "session/\(self.session.id)/window/minimize", data: nil,
                                                    context: SwiftContext(fileID: fileID, line: line, function: function),
                                                    origin: .window(self),
                                                    invoker: #function)
        let parser = try JSONParser(data: data).decode(JSONParser.self, forKey: "value")
        
        return try CGRect(x: parser.decode(Double.self, forKey: "x"),
                          y: parser.decode(Double.self, forKey: "y"),
                          width: parser.decode(Double.self, forKey: "width"),
                          height: parser.decode(Double.self, forKey: "height"))
    }
    
    /// Enters full screen.
    ///
    /// > First Responder:
    /// > The first responder is switched to `self`.
    ///
    /// The coordinate systems for WebDriver window rect and `CGRect` are essentially the same in terms of their basic structure and how they define the window's position and size. See ``frame`` for more information.
    ///
    /// - Returns: The frame for the first responder (ie, `self`).
    @discardableResult
    public func fullscreen(fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function) async throws -> CGRect {
        try await self.becomeFirstResponder(fileID: fileID, line: line, function: function)
        
        let (data, _) = try await self.session.data(.post, "session/\(self.session.id)/window/minimize", data: nil,
                                                    context: SwiftContext(fileID: fileID, line: line, function: function),
                                                    origin: .window(self),
                                                    invoker: #function)
        let parser = try JSONParser(data: data).decode(JSONParser.self, forKey: "value")
        
        return try CGRect(x: parser.decode(Double.self, forKey: "x"),
                          y: parser.decode(Double.self, forKey: "y"),
                          width: parser.decode(Double.self, forKey: "width"),
                          height: parser.decode(Double.self, forKey: "height"))
    }
        
    
}
