//
//  ServerError.swift
//  WebDriver
//
//  Created by Vaida on 2/26/25.
//

import Foundation
import Essentials
import DetailedDescription


/// Indicates web driver error.
public struct WebDriverError: GenericError, @unchecked Sendable {
    
    /// The error code defined by the web driver protocol.
    public let code: ErrorCode
    
    /// The HTTP code.
    public let statusCode: Int
    
    /// The error message provided by the server.
    public let message: String
    
    /// The stack trace provided by the server.
    public let stackTrace: String
    
    /// Additionally data provided by the server.
    public let data: JSONParser?
    
    /// The Swift context from which the error occurred.
    ///
    /// This is the context of the caller causing the error.
    public let context: SwiftContext
    
    /// The element that caused the error.
    public let origin: Origin
    
    /// The method or function that invoked the operation resulting in this error.
    ///
    /// This identifies where the error originated from within the call chain. The *caller* is defined as the first public API.
    ///
    /// When you are provided both the `invoker` and the `context`. Please use the `context` to determine the root cause.
    public let invoker: StaticString
    
    public var title: String? {
        self.code.description
    }
    
    
    init(parser: JSONParser, response: HTTPURLResponse, context: SwiftContext, origin: Origin, invoker: StaticString) throws {
        self.statusCode = response.statusCode
        self.code = try ErrorCode(rawValue: parser["error"])
        self.message = try parser["message"]
        self.stackTrace = try parser["stacktrace"]
        self.data = try? parser.object("data")
        
        self.context = context
        self.origin = origin
        self.invoker = invoker
    }
    
    
    public static func == (_ lhs: WebDriverError, _ rhs: WebDriverError) -> Bool {
        lhs.statusCode == rhs.statusCode &&
        lhs.stackTrace == rhs.stackTrace &&
        lhs.context == rhs.context &&
        lhs.invoker == rhs.invoker &&
        lhs.origin == rhs.origin
    }
    
    public enum Origin: Equatable, CustomStringConvertible, DetailedStringConvertible {
        case session(Session)
        case window(Session.Window)
        case element(Session.Window.Element)
        
        public var description: String {
            switch self {
            case .session(let session):
                session.description
            case .window(let window):
                window.description
            case .element(let element):
                element.debugDescription
            }
        }
        
        public func detailedDescription(using descriptor: DetailedDescription.Descriptor<WebDriverError.Origin>) -> any DescriptionBlockProtocol {
            switch self {
            case .session(let session):
                descriptor.constant(session.description)
            case .window(let window):
                descriptor.constant(window.description)
            case .element(let element):
                descriptor.value("", of: element)
            }
        }
    }
    
}


extension WebDriverError: CustomStringConvertible, DetailedStringConvertible {
    
    public func detailedDescription(using descriptor: DetailedDescription.Descriptor<WebDriverError>) -> any DescriptionBlockProtocol {
        descriptor.container("Error: \(self.code.description)") {
            descriptor.constant("message: \(self.message)")
            descriptor.value(for: \.context)
            descriptor.value(for: \.origin)
            descriptor.value(for: \.invoker)
        }
    }
    
    public var debugDescription: String {
        self.detailedDescription
    }
    
    public var description: String {
        self.detailedDescription
    }
    
}
