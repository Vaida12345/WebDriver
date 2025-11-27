//
//  SessionStatus.swift
//  WebDriver
//
//  Created by Vaida on 2/26/25.
//

import Foundation
import Essentials
import JSONParser


extension Session {
    
    public struct Status: Sendable {
        
        public let isReady: Bool
        
        public let message: String
        
        
        init(parser: JSONParser) throws {
            let parser = try parser.decode(JSONParser.self, forKey: "value")
            self.isReady = try parser.decode(Bool.self, forKey: "ready")
            self.message = try parser.decode(String.self, forKey: "message")
        }
        
    }
}
