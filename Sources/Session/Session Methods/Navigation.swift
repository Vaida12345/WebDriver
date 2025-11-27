//
//  Navigation.swift
//  WebDriver
//
//  Created by Vaida on 3/4/25.
//

import Foundation
import Essentials
import JSONParser


extension Session {
    
    public var url: URL {
        get async throws {
            try await self.get()
        }
    }
    
    public var title: String {
        get async throws {
            let (data, _) = try await self.data(.get, "session/\(id)/title", data: nil, context: .unavailable, origin: .session(self), invoker: #function)
            return try JSONParser(data: data).decode(String.self, forKey: "value")
        }
    }
    
    
    /// Navigation to the given url.
    public func open(url: URL, fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function) async throws {
        var json: [String : Any] = [:]
        json["url"] = url.absoluteString
        let _ = try await self.data(.post, "session/\(id)/url", json: json,
                                    context: SwiftContext(fileID: fileID, line: line, function: function),
                                    origin: .session(self),
                                    invoker: #function)
    }
    
    /// Gets the current URL.
    public func get(fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function) async throws -> URL {
        let (data, _) = try await self.data(.get, "session/\(id)/url", data: nil,
                                            context: SwiftContext(fileID: fileID, line: line, function: function),
                                            origin: .session(self),
                                            invoker: #function)
        let string = try JSONParser(data: data).decode(String.self, forKey: "value")
        return URL(string: string)!
    }
    
    
    /// Go back.
    public func back(fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function) async throws {
        let _ = try await self.data(.post, "session/\(id)/back", data: nil,
                                    context: SwiftContext(fileID: fileID, line: line, function: function),
                                    origin: .session(self),
                                    invoker: #function)
    }
    
    /// Go forward.
    public func forward(fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function) async throws {
        let _ = try await self.data(.post, "session/\(id)/forward", data: nil,
                                    context: SwiftContext(fileID: fileID, line: line, function: function),
                                    origin: .session(self),
                                    invoker: #function)
    }
    
    /// Refresh.
    public func refresh(fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function) async throws {
        let _ = try await self.data(.post, "session/\(id)/refresh", data: nil,
                                    context: SwiftContext(fileID: fileID, line: line, function: function),
                                    origin: .session(self),
                                    invoker: #function)
    }
    
    
    
}
