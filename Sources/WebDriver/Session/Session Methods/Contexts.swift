//
//  Context.swift
//  WebDriver
//
//  Created by Vaida on 3/4/25.
//

import Foundation
import Essentials


extension Session {
    
    /// Gets Window Handle
    ///
    /// - experiment: Currently invalid.
    public var windowHandle: JSONParser {
        get async throws {
            let (data, _) = try await self.data(.get, "session/\(sessionID)/url", data: nil)
            return try JSONParser(data: data)
        }
    }
    
    /// Close the window.
    public func closeWindow() async throws -> JSONParser {
        let (data, _) = try await self.data(.delete, "session/\(sessionID)/window", data: nil)
        return try JSONParser(data: data)
    }
    
    /// Switch To Window.
    public func `switch`(to handle: WindowHandle) async throws {
        let _ = try await self.data(.post, "session/\(sessionID)/window", json: ["handle" : handle.id])
    }
    
    /// New Window
    public func new(_ type: WindowType) async throws -> NewWindowResult {
        let (data, _) = try await self.data(.post, "session/\(sessionID)/window/new", json: ["type" : type.rawValue])
        return try NewWindowResult(parser: JSONParser(data: data))
    }
    
}
