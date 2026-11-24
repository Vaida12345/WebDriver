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
import JSONParser


extension Session.Window {

    /// A script whose interpolated values are passed as script arguments.
    ///
    /// Strings, numbers, booleans, and elements become `arguments[n]`, so `"return \(text)"` is safe whatever `text` contains. Use `\(raw:)` to insert code verbatim.
    public struct ScriptExecutionInterpolation:StringInterpolationProtocol, ExpressibleByStringInterpolation, ExpressibleByExtendedGraphemeClusterLiteral {
        
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
        
        /// Inserts `code` verbatim, as part of the script source.
        ///
        /// Use it for code fragments, such as `\(raw: "document.body")`. To pass a value, use the other interpolations, which are passed as script arguments and cannot break the script.
        public mutating func appendInterpolation(raw code: some CustomStringConvertible) {
            self.command.append(code.description)
        }

        /// Passes `value` as a script argument, so that quotes or other characters in it cannot break the script.
        public mutating func appendInterpolation(_ value: String) {
            self.appendArgument(value)
        }

        /// Passes `value` as a script argument.
        public mutating func appendInterpolation(_ value: Bool) {
            self.appendArgument(value)
        }

        /// Passes `value` as a script argument.
        public mutating func appendInterpolation(_ value: some BinaryInteger) {
            self.appendArgument(Int(value))
        }

        /// Passes `value` as a script argument.
        public mutating func appendInterpolation(_ value: some BinaryFloatingPoint) {
            self.appendArgument(Double(value))
        }

        /// Passes `element` as a script argument, which the script receives as the DOM element.
        public mutating func appendInterpolation(_ element: Element) {
            self.appendArgument(["element-6066-11e4-a52e-4f735466cecf" : element.id])
        }

        private mutating func appendArgument(_ value: Any) {
            self.command.append("arguments[\(self.args.count)]")
            self.args.append(value)
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
    public func execute(_ command: ScriptExecutionInterpolation, async: Bool = false, fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function) async throws -> sending JSONParser {
        try await self.execute(
            command.command,
            args: command.args,
            async: async,
            fileID: fileID, line: line, function: function
        )
    }
}
