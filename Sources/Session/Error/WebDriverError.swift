//
//  ServerError.swift
//  WebDriver
//
//  Created by Vaida on 2/26/25.
//

import Foundation
import Essentials
import DetailedDescription
import JSONParser


/// Indicates web driver error.
public struct WebDriverError: GenericError, @unchecked Sendable {
   
    /// The error code defined by the web driver protocol.
    public let code: ErrorCode
    
    /// The HTTP code.
    public let statusCode: Int
    
    /// The error message provided by the server.
    public let message: String
    
    /// The stack trace provided by the server.
    public let stackTrace: String?
    
    /// Additionally data provided by the server.
    public let data: JSONParser?
    
    /// The Swift context from which the error occurred.
    ///
    /// This is the context of the caller causing the error.
    public let context: SwiftContext
    
    /// The element that caused the error.
    public let origin: Origin
    
    /// A short HTML summary of the ``origin`` element, captured when the error occurred.
    ///
    /// This is `nil` if the origin is not an element, or if the element could no longer be read, for example because it is stale.
    ///
    /// - SeeAlso: ``Session/Window-swift.struct/Element/summary``
    public let elementSummary: String?
    
    /// The method or function that invoked the operation resulting in this error.
    ///
    /// This identifies where the error originated from within the call chain. The *caller* is defined as the first public API.
    ///
    /// When you are provided both the `invoker` and the `context`. Please use the `context` to determine the root cause.
    public let invoker: StaticString
    
    public var title: String? {
        self.code.description
    }
    
    
    init(parser: JSONParser, response: HTTPURLResponse, context: SwiftContext, origin: Origin, elementSummary: String? = nil, invoker: StaticString) throws {
        self.statusCode = response.statusCode
        self.code = try ErrorCode(rawValue: parser.decode(String.self, forKey: "error"))
        self.message = try parser.decode(String.self, forKey: "message")
        self.stackTrace = try parser.decodeIfPresent(String.self, forKey: "stacktrace")
        self.data = try? parser.decode(JSONParser.self, forKey: "data")
        
        self.context = context
        self.origin = origin
        self.elementSummary = elementSummary
        self.invoker = invoker
    }
    
    internal init(code: WebDriverError.ErrorCode, statusCode: Int, message: String, stackTrace: String? = nil, data: JSONParser? = nil, context: SwiftContext, origin: WebDriverError.Origin, elementSummary: String? = nil, invoker: StaticString) {
        self.code = code
        self.statusCode = statusCode
        self.message = message
        self.stackTrace = stackTrace
        self.data = data
        self.context = context
        self.origin = origin
        self.elementSummary = elementSummary
        self.invoker = invoker
    }
    
    
    public static func == (_ lhs: WebDriverError, _ rhs: WebDriverError) -> Bool {
        lhs.code == rhs.code &&
        lhs.message == rhs.message &&
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
                descriptor.raw(session.description)
            case .window(let window):
                descriptor.raw(window.description)
            case .element(let element):
                descriptor.value("", of: element)
            }
        }
    }
    
}


extension WebDriverError: CustomStringConvertible, DetailedStringConvertible {
    
    public func detailedDescription(using descriptor: DetailedDescription.Descriptor<WebDriverError>) -> any DescriptionBlockProtocol {
        descriptor.container("Error: \(self.code.description)") {
            descriptor.raw("message: \(self.message)")
            descriptor.value(for: \.context)
            descriptor.value(for: \.origin)
            if let elementSummary {
                descriptor.raw("element: \(elementSummary)")
            }
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
