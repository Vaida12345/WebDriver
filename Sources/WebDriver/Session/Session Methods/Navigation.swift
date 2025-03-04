//
//  Navigation.swift
//  WebDriver
//
//  Created by Vaida on 3/4/25.
//

import Foundation


extension Session {
    
    /// Navigation to the given url.
    public func open(url: URL) async throws {
        var json: [String : Any] = [:]
        json["url"] = url.absoluteString
        let (data, response) = try await self.data(.post, "session/\(sessionID)/url", json: json)
    }
    
}
