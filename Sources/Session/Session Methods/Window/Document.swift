//
//  Document.swift
//  WebDriver
//
//  Created by Vaida on 3/7/25.
//

import Essentials
import Foundation
import CoreGraphics
import NativeImage


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
    ///
    /// - SeeAlso: Use string interpolation to form commands: ``Session/Window-swift.struct/execute(_:async:)``
    public func execute(_ command: String, args: [Any], async: Bool = false) async throws -> sending JSONParser {
        try await self.becomeFirstResponder()
        
        let (data, _) = try await self.session.data(
            .post,
            "session/\(self.session.id)/execute/\(async ? "async" : "sync")",
            json: ["script" : command, "args" : args]
        )
        return try JSONParser(data: data)
    }
    
    /// Takes a screenshot of the current browser window.
    ///
    /// This endpoint captures the entire viewport as a base64-encoded PNG image.
    ///
    /// > First Responder:
    /// > The first responder is switched to `self`.
    public func screenshot() async throws -> sending NativeImage {
        try await self.becomeFirstResponder()
        
        let (result, _) = try await self.session.data(.get, "session/\(self.session.id)/screenshot", data: nil)
        let base64 = try JSONParser(data: result)["value"]
        let data = Data(base64Encoded: base64)!
        return NativeImage(data: data)!
    }
    
}
