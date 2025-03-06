//
//  Window Position.swift
//  WebDriver
//
//  Created by Vaida on 3/5/25.
//

import Essentials
import CoreGraphics


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
            
            let (data, _) = try await self.session.data(.get, "session/\(self.session.id)/window/rect", data: nil)
            let parser = try JSONParser(data: data).object("value")
            
            return try CGRect(x: parser["x", .numeric],
                              y: parser["y", .numeric],
                              width: parser["width", .numeric],
                              height: parser["height", .numeric])
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
    public func setFrame(_ frame: CGRect) async throws -> CGRect {
        try await self.setFrame(x: frame.origin.x, y: frame.origin.y, width: frame.width, height: frame.height)
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
    public func setFrame(x: CGFloat?, y: CGFloat?, width: CGFloat?, height: CGFloat?) async throws -> CGRect {
        try await self.becomeFirstResponder()
        
        var parameters: [String: Any] = [:]
        
        if let x = x { parameters["x"] = x }
        if let y = y { parameters["y"] = y }
        if let width = width { parameters["width"] = width }
        if let height = height { parameters["height"] = height }
        
        let (data, _) = try await self.session.data(.post, "session/\(self.session.id)/window/rect", json: parameters)
        let parser = try JSONParser(data: data).object("value")
        
        return try CGRect(x: parser["x", .numeric],
                          y: parser["y", .numeric],
                          width: parser["width", .numeric],
                          height: parser["height", .numeric])
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
    public func maximize() async throws -> CGRect {
        try await self.becomeFirstResponder()
        
        let (data, _) = try await self.session.data(.post, "session/\(self.session.id)/window/maximize", data: nil)
        let parser = try JSONParser(data: data).object("value")
        
        return try CGRect(x: parser["x", .numeric],
                          y: parser["y", .numeric],
                          width: parser["width", .numeric],
                          height: parser["height", .numeric])
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
    public func minimize() async throws -> CGRect {
        try await self.becomeFirstResponder()
        
        let (data, _) = try await self.session.data(.post, "session/\(self.session.id)/window/minimize", data: nil)
        let parser = try JSONParser(data: data).object("value")
        
        return try CGRect(x: parser["x", .numeric],
                          y: parser["y", .numeric],
                          width: parser["width", .numeric],
                          height: parser["height", .numeric])
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
    public func fullscreen() async throws -> CGRect {
        try await self.becomeFirstResponder()
        
        let (data, _) = try await self.session.data(.post, "session/\(self.session.id)/window/minimize", data: nil)
        let parser = try JSONParser(data: data).object("value")
        
        return try CGRect(x: parser["x", .numeric],
                          y: parser["y", .numeric],
                          width: parser["width", .numeric],
                          height: parser["height", .numeric])
    }
        
    
}
