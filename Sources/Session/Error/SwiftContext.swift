//
//  SwiftContext.swift
//  WebDriver
//
//  Created by Vaida on 2025-10-20.
//

import Foundation


/// The Swift context from which the error occurred.
public struct SwiftContext: CustomStringConvertible, Equatable, Sendable {
    
    public let fileID: StaticString
    
    public let line: Int
    
    public let function: StaticString
    
    
    public var description: String {
        if line != -1 {
            "\(fileID):\(line) in \(function)"
        } else {
            "\(self.function)"
        }
    }
    
    init(fileID: StaticString, line: Int, function: StaticString) {
        self.fileID = fileID
        self.line = line
        self.function = function
    }
    
    /// Indicates it is impossible to obtain the context.
    ///
    /// For example, the caller may be a computed property.
    public static var unavailable: SwiftContext {
        SwiftContext(fileID: "<unavailable>", line: -1, function: "<unavailable>")
    }
    
}


extension StaticString: @retroactive Equatable {
    public static func == (lhs: StaticString, rhs: StaticString) -> Bool {
        lhs.withUTF8Buffer { lhs in
            rhs.withUTF8Buffer { rhs in
                guard lhs.count == rhs.count else { return false }
                return memcmp(lhs.baseAddress, rhs.baseAddress, lhs.count) == 0
            }
        }
    }
}
