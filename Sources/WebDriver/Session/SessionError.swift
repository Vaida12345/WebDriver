//
//  SessionError.swift
//  WebDriver
//
//  Created by Vaida on 2/26/25.
//

import Essentials


public enum SessionError: GenericError {
    
    case initialConnectionFailed(String, any Error)
    case connectionLost
    
    
    public var title: String? {
        switch self {
        case .initialConnectionFailed:
            "Initial connection to the server failed"
        case .connectionLost:
            "Connection Lost"
        }
    }
    
    public var message: String {
        switch self {
        case .initialConnectionFailed(let serviceName, let error):
            "Please ensure the server `\(serviceName)` is running. The error is: \(error)"
        case .connectionLost:
            "Connection Lost"
        }
    }
    
    
    public static func == (_ lhs: Self, _ rhs: Self) -> Bool {
        lhs.message == rhs.message
    }
    
}
