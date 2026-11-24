//
//  SessionError.swift
//  WebDriver
//
//  Created by Vaida on 2/26/25.
//

import Essentials


extension Session {
    /// Error introduced in this package.
    public enum SessionError: GenericError {
        
        case initialConnectionFailed(String, any Error)
        case connectionLost
        case badResponse(code: Int, message: String?)
        case invalidURL(String)
        /// The response could not be decoded as the expected content, such as a PNG image.
        case undecodableContent(expected: String)


        public var title: String? {
            switch self {
            case .initialConnectionFailed:
                "Initial connection to the server failed"
            case .connectionLost:
                "Connection Lost"
            case .badResponse(let code, _):
                "Bad Response (Code \(code))"
            case .invalidURL:
                "Invalid URL"
            case .undecodableContent:
                "Undecodable Content"
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
            case .invalidURL(let string):
                "\"\(string)\" is not a valid URL"
            case .undecodableContent(let expected):
                "The server's response could not be decoded as \(expected)."
            }
        }
        
        
        public static func == (_ lhs: SessionError, _ rhs: SessionError) -> Bool {
            lhs.message == rhs.message
        }
        
    }
}
