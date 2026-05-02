//
//  WebDriver.swift
//  WebDriver
//
//  Created by Vaida on 2/26/25.
//

import Foundation


/// The container class for all drivers.
///
/// - Note: In this package, `firstMatch` is ignored.
///
/// ## Topics
/// ### Parameters
/// - ``PageLoadStrategy``
public enum WebDriver {
    
}


/// The actual protocol that all drivers conform.
public protocol WebDriverProtocol {
    
    /// The capabilities required.
    var capabilities: [String : Any] { get }
    
    var flags: WebDriverInitializationFlags { get }
    
    /// Creates a new session.
    func startSession(urlSessionConfiguration: URLSessionConfiguration, fileID: StaticString, line: Int, function: StaticString) async throws -> Session
    
    /// Links an existing session.
    func linkSession(url: URL, port: UInt16, fileID: StaticString, line: Int, function: StaticString) async throws -> Session
    
    init(capabilities: [String : Any], flags: WebDriverInitializationFlags) throws(WebDriver.InitializationError)
    
    init() throws(WebDriver.InitializationError)
    
    /// Whether the necessary driver is installed on local device.
    static var isAvailable: Bool { get }
    
}


public struct WebDriverInitializationFlags: OptionSet, Sendable {
    public var rawValue: UInt
    
    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }
    
    static let deleteProfileAfterUse = WebDriverInitializationFlags(rawValue: 1 << 0)
}


public extension WebDriverProtocol {
    
    internal func appendingCapability(key: String, value: String) throws(WebDriver.InitializationError) -> Self {
        try Self(capabilities: self.capabilities.merging([key : value], uniquingKeysWith: { $1 }), flags: self.flags)
    }
    
    /// Identifies the user agent.
    func browserName(_ name: String) throws(WebDriver.InitializationError) -> Self {
        try self.appendingCapability(key: "browserName", value: name)
    }
    
    /// Identifies the version of the user agent.
    func browserVersion(_ version: String) throws(WebDriver.InitializationError) -> Self {
        try self.appendingCapability(key: "browserVersion", value: version)
    }
    
    /// Identifies the operating system of the endpoint node.
    ///
    /// - term Endpoint node: An endpoint node is the final remote end in a chain of nodes that is not an intermediary node. The endpoint node is implemented by a user agent or a similar program.
    func platformName(_ name: String) throws -> Self {
        try self.appendingCapability(key: "platformName", value: name)
    }
    
    /// Defines the session's page load strategy.
    func pageLoadStrategy(_ strategy: PageLoadStrategy = .normal) throws -> Self {
        try self.appendingCapability(key: "pageLoadStrategy", value: strategy.rawValue)
    }
    
    /// Links an existing session.
    ///
    /// - important: `url` must not contain a schema, otherwise `InitializationError`.
    func linkSession(url: URL = URL(string: "127.0.0.1")!, port: UInt16 = 4444, fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function) async throws -> Session {
        guard !url.absoluteString.contains("//") else { throw WebDriver.InitializationError.urlNotSupported }
        return try await Session(
            launcher: LinkedLauncher(driver: self, url: url, port: port), context: SwiftContext(fileID: fileID, line: line, function: function),
            invoker: #function
        )
    }
    
}
