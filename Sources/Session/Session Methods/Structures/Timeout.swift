//
//  Timeout.swift
//  WebDriver
//
//  Created by Vaida on 3/4/25.
//

import Foundation
import Essentials


public struct Timeout: Sendable, CustomStringConvertible, Equatable {
    
    /// The maximum time that WebDriver will wait for a synchronous JavaScript to execute before throwing an error.
    ///
    /// This is particularly useful when you execute scripts using WebDriver's `execute_script` method. If the script takes longer than the set timeout, the WebDriver throws a "script timeout" error (`script timeout`).
    public var script: Duration?
    
    /// The maximum time WebDriver will wait for a page load to complete before throwing a "timeout" error.
    ///
    /// This is crucial during navigation activities (like clicking a link where the destination page takes a long time to fully load). If the navigation takes longer than this timeout, WebDriver will terminate the operation and return a `timeout` error.
    public var pageLoad: Duration?
    
    /// The maximum time that WebDriver should wait when searching for elements.
    ///
    /// If an element is not immediately visible or available, WebDriver will keep retrying the find operation for the duration specified by the implicit timeout. After exceeding this time, if the element is still not found, only then it will throw a `no such element` error.
    public var implicit: Duration?
    
    
    public var description: String {
        var output = ""
        self.write(to: &output)
        return output
    }
    
    public func write(to stream: inout some TextOutputStream) {
        stream.write("Timeout(")
        var requiresComma = false
        if let script {
            stream.write("script: \(script)")
            requiresComma = true
        }
        if let pageLoad {
            if requiresComma { stream.write(", ") }
            stream.write("pageLoad: \(pageLoad)")
            requiresComma = true
        }
        if let implicit {
            if requiresComma { stream.write(", ") }
            stream.write("implicit: \(implicit)")
        }
        stream.write(")")
    }
    
    public func encode() -> [String : Any] {
        var results: [String : Any] = [:]
        if let script {
            results["script"] = Int(script.seconds * 1e3)
        }
        if let pageLoad {
            results["pageLoad"] = Int(pageLoad.seconds * 1e3)
        }
        if let implicit {
            results["implicit"] = Int(implicit.seconds * 1e3)
        }
        return results
    }
    
    
    init(parser: JSONParser) throws {
        let value = try parser.object("value")
        
        let script = try value["script", .numeric]
        self.script = script == 0 ? nil : .milliseconds(script)
        
        let pageLoad = try value["pageLoad", .numeric]
        self.pageLoad = pageLoad == 0 ? nil : .milliseconds(pageLoad)
        
        let implicit = try value["implicit", .numeric]
        self.implicit = implicit == 0 ? nil : .milliseconds(implicit)
    }
    
    public init(script: Duration? = nil, pageLoad: Duration? = nil, implicit: Duration? = nil) {
        self.script = script
        self.pageLoad = pageLoad
        self.implicit = implicit
    }
    
}


extension Session {
    
    /// Navigation to the given url.
    public var timeout: Timeout {
        get async throws {
            let (data, _) = try await self.data(.get, "session/\(id)/timeouts", data: nil)
            return try Timeout(parser: JSONParser(data: data))
        }
    }
    
    public func set(timeout: Timeout) async throws {
        let _ = try await self.data(.post, "session/\(id)/timeouts", json: timeout.encode())
    }
    
}
