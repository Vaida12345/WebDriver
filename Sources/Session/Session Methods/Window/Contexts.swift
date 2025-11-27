//
//  Context.swift
//  WebDriver
//
//  Created by Vaida on 3/4/25.
//

import Foundation
import Essentials
import JSONParser


extension Session {
    
    /// Gets the current top level window.
    public var window: Window {
        get async throws {
            let (data, _) = try await self.data(.get, "session/\(id)/window", data: nil, context: .unavailable, origin: .session(self), invoker: #function)
            let parser = try JSONParser(data: data)
            
            return try Window(session: self, id: parser.decode(String.self, forKey: "value"), context: SwiftContext(fileID: "<unavailable>", line: -1, function: "Session.window"))
        }
    }
    
    /// Get the Window.
    ///
    /// The order in which the windows are returned is arbitrary.
    public var windows: [Window] {
        get async throws {
            let (data, _) = try await self.data(.get, "session/\(id)/window/handles", data: nil, context: .unavailable, origin: .session(self), invoker: #function)
            return try JSONParser(data: data).decode([String].self, forKey: "value").map({ Window(session: self, id: $0, context: SwiftContext(fileID: "<unavailable>", line: -1, function: "Session.windows")) })
        }
    }
    
    /// New Window
    public func makeWindow(type: Window.WindowType, fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function) async throws -> Window {
        let (data, _) = try await self.data(.post, "session/\(self.id)/window/new", json: ["type" : type.rawValue],
                                            context: SwiftContext(fileID: fileID, line: line, function: function),
                                            origin: .session(self),
                                            invoker: #function)
        let parser = try JSONParser(data: data)
        let value = try parser.decode(JSONParser.self, forKey: "value")
        let id = try value.decode(String.self, forKey: "handle")
        let type = try Window.WindowType(rawValue: value.decode(String.self, forKey: "type"))!
        
        return Window(session: self, id: id, type: type, context: SwiftContext(fileID: fileID, line: line, function: function))
    }
    
}
