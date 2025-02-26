//
//  SessionStatus.swift
//  WebDriver
//
//  Created by Vaida on 2/26/25.
//

import Foundation


public struct SessionStatus: Sendable {
    
    public let isReady: Bool
    
    public let message: String
    
    
    init(parser: JSONParser) throws {
        self.isReady = try parser.object("value")["ready", .bool]
        self.message = try parser.object("value")["message"]
    }
    
}
