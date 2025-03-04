//
//  Session.swift
//  WebDriver
//
//  Created by Vaida on 2/26/25.
//

import Foundation
import OSLog


public final class Session<Driver: WebDriverProtocol, Launcher: WebDriverLauncher>: @unchecked Sendable {
    
    public let launcher: Launcher
    
    public let session: URLSession
    
    public private(set) var sessionID: String
    
    
    init(launcher: Launcher) async throws {
        self.session = URLSession(configuration: .ephemeral)
        self.sessionID = ""
        self.launcher = launcher
        
        let driver = launcher.driver
        
        do {
            let results = try await self.data(.post, "session", json: ["capabilities": ["alwaysMatch" : driver.capabilities]])
            let parser = try JSONParser(data: results.0)
            self.sessionID = try parser.object("value")["sessionId"]
            
            guard let value = String(data: results.0, encoding: .utf8) else { throw SessionError.connectionLost }
            print(value)
            print(results.1)
            
        } catch let error as ServerError {
            throw error
        } catch {
            let service: String
            if driver is WebDriver.Firefox {
                service = "geckodriver"
            } else {
                service = "(unknown)"
            }
            
            throw SessionError.initialConnectionFailed(service, error)
        }
    }
    
    
    public func makeRequest(
        _ method: HTTPMethod,
        _ uri: String,
        data: Data?
    ) -> URLRequest {
        var request = URLRequest(url: self.launcher.baseURL.appending(path: uri))
        request.httpMethod = method.rawValue
        if let data {
            request.httpBody = data
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let logger = Logger(subsystem: "WebDriver", category: "Session Request")
            if let object = try? JSONSerialization.jsonObject(with: data),
               let stringData = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]) {
                logger.trace("\(String(data: stringData, encoding: .utf8)!)")
            }
        }
        return request
    }
    
    public func data(
        _ method: HTTPMethod,
        _ uri: String,
        data: Data?
    ) async throws -> (Data, URLResponse) {
        let request = self.makeRequest(method, uri, data: data)
        let (data, response) = try await self.session.data(for: request)
        
        let responseLogger = Logger(subsystem: "WebDriver", category: "Session Response: Info")
        responseLogger.trace("\(response)")
        
        let logger = Logger(subsystem: "WebDriver", category: "Session Response: Body")
        let object = try JSONSerialization.jsonObject(with: data)
        let stringData = try JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted])
        logger.trace("\(String(data: stringData, encoding: .utf8)!)")
        
        guard let response = response as? HTTPURLResponse else { return (data, response) }
        
        
        switch response.statusCode {
        case 500, 400:
            let parser = try JSONParser(data: data).object("value")
            throw try ServerError(
                code: response.statusCode,
                title: parser["error"],
                message: parser["message"],
                stackTrace: parser["stacktrace"]
            )
            
        default:
            break
        }
        
        return (data, response)
    }
    
    public func data(
        _ method: HTTPMethod,
        _ uri: String,
        json: [String : Any]
    ) async throws -> (Data, URLResponse) {
        try await self.data(method, uri, data: JSONSerialization.data(withJSONObject: json))
    }
    
    public func close() async throws {
        let _ = try await self.data(.delete, "session/\(sessionID)", data: nil)
        self.launcher.stop()
    }
    
    
    public func status() async throws -> SessionStatus {
        let request = try await self.data(.get, "status", data: nil)
        
        return try SessionStatus(parser: JSONParser(data: request.0))
    }
    
}


public extension Session {
    
    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
    }
    
}
