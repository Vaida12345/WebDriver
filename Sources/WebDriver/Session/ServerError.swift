//
//  ServerError.swift
//  WebDriver
//
//  Created by Vaida on 2/26/25.
//

import Foundation
import Essentials


/// Indicates the error received from server.
public struct ServerError: GenericError {
    
    /// The HTTP code.
    public let code: Int
    
    /// The error title that may have been provided by the server.
    public let title: String?
    
    /// The error message provided by the server.
    public let message: String
    
    /// The stack trace provided by the server.
    public let stackTrace: String
    
    
    public func write(to stream: inout some TextOutputStream) {
        if let title {
            stream.write("\(title): \(message)")
        } else {
            stream.write(message)
        }
        
        if !stackTrace.isEmpty {
            stream.write("\n\tStack trace:\n")
            stream.write(stackTrace)
        }
    }
    
    public var description: String {
        var result = ""
        self.write(to: &result)
        return result
    }
    
}
