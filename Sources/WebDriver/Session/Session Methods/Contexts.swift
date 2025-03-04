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
    
    /// New Window
    public func newWindow() async throws {
        let (data, _) = try await self.data(.post, "session/\(sessionID)/window/new", data: nil)
        print(try JSONSerialization.jsonObject(with: data))
    }
    
}
