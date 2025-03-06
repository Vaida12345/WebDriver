//
//  SessionError.swift
//  WebDriver
//
//  Created by Vaida on 2/26/25.
//

import Essentials


/// Error introduced in this package.
public enum SessionError: GenericError {
    
    case initialConnectionFailed(String, any Error)
    case connectionLost
    case badResponse(code: Int, message: String?)
    
    
    public var title: String? {
        switch self {
        case .initialConnectionFailed:
            "Initial connection to the server failed"
        case .connectionLost:
            "Connection Lost"
        case .badResponse(let code, _):
            "Bad Response (Code \(code))"
        }
    }
    
    public var message: String {
        switch self {
        case .initialConnectionFailed(let serviceName, let error):
            "Please ensure the server `\(serviceName)` is running. The error is: \(error)"
        case .connectionLost:
            "Connection Lost"
        case .badResponse(_, let message):
            message ?? "(not decodable as String)"
        }
    }
    
    
    public static func == (_ lhs: Self, _ rhs: Self) -> Bool {
        lhs.message == rhs.message
    }
    
}
