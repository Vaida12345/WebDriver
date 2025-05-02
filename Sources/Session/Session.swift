//
//  Session.swift
//  WebDriver
//
//  Created by Vaida on 2/26/25.
//

import Foundation
import Essentials
import OSLog


/// A connection session.
///
/// All interactions with the browser it controls are communicated via a session.
///
/// To obtain a session, call the ``WebDriver/WebDriverProtocol/startSession()``. After you are finished with a session, close the session using ``close()``.
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
public struct Session: @unchecked Sendable, Identifiable, CustomStringConvertible {
    
    /// The launcher that launched the backend for this session.
    ///
    /// Through the launcher, the launch args, the backend url, and the service used can be obtained.
    internal let launcher: any WebDriverLauncher
    
    /// The shared url session for this instance. All connection will be transmitted through this session.
    internal let session: URLSession
    
    /// The session ID identified by the backend.
    public var id: String
    
    
    public var description: String {
        "Session<\(type(of: launcher.driver))>"
    }
    
    
    init(launcher: any WebDriverLauncher) async throws {
        self.session = URLSession(configuration: .ephemeral)
        self.id = ""
        self.launcher = launcher
        
        let driver = launcher.driver
        
        let results = try await self.data(.post, "session", json: ["capabilities": ["alwaysMatch" : driver.capabilities]])
        let parser = try JSONParser(data: results.0)
        self.id = try parser.object("value")["sessionId"]
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
        
        let logger = Logger(subsystem: "Session", category: #function)
        logger.info("Made request: \(request)")
        
        return request
    }
    
    func data(
        _ method: HTTPMethod,
        _ uri: String,
        data: Data?
    ) async throws -> (Data, URLResponse) {
        let request = self.makeRequest(method, uri, data: data)
        let (data, response) = try await self.session.data(for: request)
        
        guard let response = response as? HTTPURLResponse else { return (data, response) }
        
        switch response.statusCode {
        case 200:
            return (data, response)
            
        case 400, 404, 405, 500:
            do {
                let parser = try JSONParser(data: data).object("value")
                throw try ServerError(parser: parser, response: response)
            } catch let error as ServerError {
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
        json: [String : Any]
    ) async throws -> (Data, URLResponse) {
        try await self.data(method, uri, data: JSONSerialization.data(withJSONObject: json))
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
