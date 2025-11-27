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
    var capabilities: [String : Any] { get set }
    
    /// Creates a new session.
    func startSession(urlSessionConfiguration: URLSessionConfiguration, fileID: StaticString, line: Int, function: StaticString) async throws -> Session
    
    /// Links an existing session.
    func linkSession(url: URL, port: UInt16, fileID: StaticString, line: Int, function: StaticString) async throws -> Session
    
    init(capabilities: [String : Any])
    
}


public extension WebDriverProtocol {
    
    internal func appendingCapability(key: String, value: String) -> Self {
        Self(capabilities: self.capabilities.merging([key : value], uniquingKeysWith: { $1 }))
    }
    
    /// Identifies the user agent.
    func browserName(_ name: String) -> Self {
        self.appendingCapability(key: "browserName", value: name)
    }
    
    /// Identifies the version of the user agent.
    func browserVersion(_ version: String) -> Self {
        self.appendingCapability(key: "browserVersion", value: version)
    }
    
    /// Identifies the operating system of the endpoint node.
    ///
    /// - term Endpoint node: An endpoint node is the final remote end in a chain of nodes that is not an intermediary node. The endpoint node is implemented by a user agent or a similar program.
    func platformName(_ name: String) -> Self {
        self.appendingCapability(key: "platformName", value: name)
    }
    
    /// Defines the session's page load strategy.
    func pageLoadStrategy(_ strategy: PageLoadStrategy = .normal) -> Self {
        self.appendingCapability(key: "pageLoadStrategy", value: strategy.rawValue)
    }
    
    /// Links an existing session.
    func linkSession(url: URL = URL(string: "127.0.0.1")!, port: UInt16 = 4444, fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function) async throws -> Session {
        try await Session(launcher: LinkedLauncher(driver: self, url: url, port: port), context: SwiftContext(fileID: fileID, line: line, function: function),
                          invoker: #function)
    }
    
}
