//
//  Session.swift
//  WebDriver
//
//  Created by Vaida on 2/26/25.
//

import Foundation
import Essentials
import OSLog
import JSONParser
import os


/// A connection session.
///
/// All interactions with the browser it controls are communicated via a session.
///
/// To obtain a session, call the ``WebDriver/WebDriverProtocol/startSession()``. After you are finished with a session, close the session using ``close()``.
///
/// A session is a reference type: copies share one connection to the driver. The connection is invalidated when the session is closed, or when the last reference to it goes away.
///
/// ## Topics
/// ### Swift Properties
/// The properties introduced by this Swift implementation.
/// - ``id``
/// - ``description``
///
/// ### Context
/// - ``window-swift.property``
/// - ``windows``
/// - ``makeWindow(type:)``
///
/// ### Essentials
/// - ``close()``
/// - ``status()``
///
/// ### Navigation
/// - ``url``
/// - ``title``
/// - ``open(url:)``
/// - ``get()``
/// - ``back()``
/// - ``forward()``
/// - ``refresh()``
///
/// ### Timeout
/// - ``timeout``
/// - ``set(timeout:)``
///
/// ### Structures
/// - ``Status``
/// - ``SessionError``
/// - ``Timeout``
public final class Session: Sendable, Identifiable, CustomStringConvertible {
    
    /// The launcher that launched the backend for this session.
    ///
    /// Through the launcher, the launch args, the backend url, and the service used can be obtained.
    internal let launcher: any WebDriverLauncher
    
    /// The shared url session for this instance. All connection will be transmitted through this session.
    internal let session: URLSession
    
    /// The identity, whose id is set once the driver has created the session.
    private let identityStorage: OSAllocatedUnfairLock<Identity>
    
    public var identity: Identity {
        self.identityStorage.withLock { $0 }
    }
    
    /// The session ID identified by the backend.
    public var id: String {
        self.identity.id
    }
    
    
    public var description: String {
        "Session<\(type(of: launcher.driver))>(identity: \(self.identity))"
    }
    
    
    init(launcher: any WebDriverLauncher, context: SwiftContext, invoker: StaticString, urlSessionConfiguration: URLSessionConfiguration = .ephemeral) async throws {
        self.session = URLSession(configuration: urlSessionConfiguration)
        self.identityStorage = OSAllocatedUnfairLock(initialState: Identity(id: "", creation: context))
        self.launcher = launcher
        
        let driver = launcher.driver
        
        let results = try await self.data(.post, "session", json: ["capabilities": ["alwaysMatch" : driver.capabilities]],
                                          context: context, origin: .session(self), invoker: invoker)
        let parser = try JSONParser(data: results.0)
        let id = try parser.decode(JSONParser.self, forKey: "value").decode(String.self, forKey: "sessionId")
        self.identityStorage.withLock { $0.id = id }
        launcher.attach(sessionID: id)
    }
    
    deinit {
        self.session.finishTasksAndInvalidate()
    }
    
    
    func makeRequest(
        _ method: HTTPMethod,
        _ uri: String,
        data: Data?
    ) -> URLRequest {
        var request = URLRequest(url: self.launcher.baseURL.appending(path: uri))
        request.httpMethod = method.rawValue
        if let data {
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = data
        } else if method == .post {
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = "{}".data(using: .utf8)
        }
        
        return request
    }
    
    func data(
        _ method: HTTPMethod,
        _ uri: String,
        data: Data?,
        context: SwiftContext,
        origin: WebDriverError.Origin,
        invoker: StaticString
    ) async throws -> (Data, URLResponse) {
        let request = self.makeRequest(method, uri, data: data)
        let (data, response) = try await self.session.data(for: request)
        
        guard let response = response as? HTTPURLResponse else { return (data, response) }
        
        switch response.statusCode {
        case 200, 201, 202, 203, 204, 205, 206, 207, 208, 226:
            return (data, response)
            
        case 400...599:
            do {
                let parser = try JSONParser(data: data).decode(JSONParser.self, forKey: "value")
                // Skipped when the element, its window, or the session is gone, as the summary could not be read.
                let code = try? parser.decode(String.self, forKey: "error")
                let isUnreadable = code.map { ["stale element reference", "no such window", "no such frame", "invalid session id"].contains($0) } ?? false
                let elementSummary: String? = if case .element(let element) = origin, !isUnreadable { await element.summaryIfAvailable } else { nil }
                throw try WebDriverError(parser: parser, response: response, context: context, origin: origin, elementSummary: elementSummary, invoker: invoker)
            } catch let error as WebDriverError {
                throw error
            } catch {
                throw SessionError.badResponse(code: response.statusCode, message: String(data: data, encoding: .utf8))
            }
            
        default:
            throw SessionError.badResponse(code: response.statusCode, message: String(data: data, encoding: .utf8))
        }
    }
    
    func data(
        _ method: HTTPMethod,
        _ uri: String,
        json: [String : Any],
        context: SwiftContext,
        origin: WebDriverError.Origin,
        invoker: StaticString
    ) async throws -> (Data, URLResponse) {
        try await self.data(method, uri, data: JSONSerialization.data(withJSONObject: json), context: context, origin: origin, invoker: invoker)
    }
    
}


extension Session {
    
    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
    }
    
}


extension Session: Equatable {
    public static func == (lhs: Session, rhs: Session) -> Bool {
        lhs.id == rhs.id
    }
}
