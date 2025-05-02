//
//  Script Execution.swift
//  WebDriver
//
//  Created by Vaida on 5/2/25.
//

import Essentials
import Foundation
import CoreGraphics
import NativeImage


extension Session.Window {
    
    public struct ScriptExecutionInterpolation: StringInterpolationProtocol, ExpressibleByStringInterpolation, ExpressibleByExtendedGraphemeClusterLiteral {
        
        var command: String
        
        var args: [Any]
        
        
        public init(literalCapacity: Int, interpolationCount: Int) {
            self.command = ""
            self.args = []
            
            self.command.reserveCapacity(literalCapacity)
            self.args.reserveCapacity(interpolationCount)
        }
        
        public mutating func appendLiteral(_ literal: String) {
            self.command.append(literal)
        }
        
        public mutating func appendInterpolation(_ value: some CustomStringConvertible) {
            self.command.append(value.description)
        }
        
        public mutating func appendInterpolation(_ element: Element) {
            self.command.append("arguments[\(self.args.count)]")
            self.args.append(["element-6066-11e4-a52e-4f735466cecf" : element.id])
        }
        
        
        public init(stringInterpolation: ScriptExecutionInterpolation) {
            self.command = stringInterpolation.command
            self.args = stringInterpolation.args
        }
        
        public init(stringLiteral value: String) {
            self.command = value
            self.args = []
        }
        
        
    }
    
    
    /// Executes the given command.
    ///
    /// > First Responder:
    /// > The first responder is switched to `self`.
    public func execute(_ command: ScriptExecutionInterpolation, async: Bool = false) async throws -> sending JSONParser {
        try await self.execute(
            command.command,
            args: command.args,
            async: async
        )
    }
}
