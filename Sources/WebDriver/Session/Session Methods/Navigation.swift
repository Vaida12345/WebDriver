//
//  Navigation.swift
//  WebDriver
//
//  Created by Vaida on 3/4/25.
//

import Foundation
import Essentials


extension Session {
    
    public var url: URL {
        get async throws {
            try await self.get()
        }
    }
    
    public var title: String {
        get async throws {
            let (data, _) = try await self.data(.get, "session/\(id)/title", data: nil)
            return try JSONParser(data: data)["value"]
        }
    }
    
    
    /// Navigation to the given url.
    public func open(url: URL) async throws {
        var json: [String : Any] = [:]
        json["url"] = url.absoluteString
        let _ = try await self.data(.post, "session/\(id)/url", json: json)
    }
    
    /// Gets the current URL.
    public func get() async throws -> URL {
        let (data, _) = try await self.data(.get, "session/\(id)/url", data: nil)
        let string = try JSONParser(data: data)["value"]
        return URL(string: string)!
    }
    
    
    /// Go back.
    public func back() async throws {
        let _ = try await self.data(.post, "session/\(id)/back", data: nil)
    }
    
    /// Go forward.
    public func forward() async throws {
        let _ = try await self.data(.post, "session/\(id)/forward", data: nil)
    }
    
    /// Refresh.
    public func refresh() async throws {
        let _ = try await self.data(.post, "session/\(id)/refresh", data: nil)
    }
    
    
    
}
