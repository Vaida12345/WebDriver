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
import JSONParser


extension Session.Window {
    
    /// A string serialization of the DOM
    ///
    /// The serialization contains the current elements and their HTML attributes, including changes made by script. It does not contain properties changed by user interaction or script, such as typed text or a clicked checkbox, nor computed styles. Use ``Element/load(_:at:)-43sms`` at ``Element/LoadSource/script`` to read those.
    ///
    /// > First Responder:
    /// > The first responder is switched to `self`.
    public var pageSource: String {
        get async throws {
            try await self.becomeFirstResponder()
            
            let (data, _) = try await self.session.data(.get, "session/\(self.session.id)/source", data: nil, context: .unavailable, origin: .window(self), invoker: #function)
            return try JSONParser(data: data).decode(String.self, forKey: "value")
        }
    }
    
    /// Executes the given command.
    ///
    /// > First Responder:
    /// > The first responder is switched to `self`.
    ///
    /// - SeeAlso: Use string interpolation to form commands: ``Session/Window-swift.struct/execute(_:async:)``
    public func execute(_ command: String, args: [Any], async: Bool = false, fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function) async throws -> sending JSONParser {
        try await self.becomeFirstResponder(fileID: fileID, line: line, function: function)
        
        let (data, _) = try await self.session.data(
            .post,
            "session/\(self.session.id)/execute/\(async ? "async" : "sync")",
            json: ["script" : command, "args" : args],
            context: SwiftContext(fileID: fileID, line: line, function: function),
            origin: .window(self),
            invoker: #function
        )
        return try JSONParser(data: data)
    }

}
