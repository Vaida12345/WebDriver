//
//  Document.swift
//  WebDriver
//
//  Created by Vaida on 3/7/25.
//

import Essentials
import CoreGraphics


extension Session.Window {
    
    /// A string serialization of the DOM
    ///
    /// > First Responder:
    /// > The first responder is switched to `self`.
    public var pageSource: String {
        get async throws {
            try await self.becomeFirstResponder()
            
            let (data, _) = try await self.session.data(.get, "session/\(self.session.id)/source", data: nil)
            return try JSONParser(data: data)["value"]
        }
    }
    
    /// Executes the given command.
    ///
    /// > First Responder:
    /// > The first responder is switched to `self`.
    public func execute(_ command: String, args: [String : String], async: Bool) async throws -> JSONParser {
        try await self.becomeFirstResponder()
        
        let (data, _) = try await self.session.data(
            .post,
            "session/\(self.session.id)/execute/\(async ? "async" : "async")",
            json: ["script" : command, "args" : args]
        )
        return try JSONParser(data: data)
    }
    
}
