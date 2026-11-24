//
//  Timeout.swift
//  WebDriver
//
//  Created by Vaida on 3/4/25.
//

import Foundation
import Essentials
import JSONParser


extension Session {
    
    public struct Timeout: Sendable, CustomStringConvertible, Equatable {
        
        /// The maximum time that WebDriver will wait for a synchronous JavaScript to execute before throwing an error.
        ///
        /// This is particularly useful when you execute scripts using WebDriver's `execute_script` method. If the script takes longer than the set timeout, the WebDriver throws a "script timeout" error (`script timeout`).
        ///
        /// `nil` leaves the timeout unchanged. Zero means the operation times out immediately.
        ///
        /// - Important: Must not be negative.
        public var script: Duration?
        
        /// The maximum time WebDriver will wait for a page load to complete before throwing a "timeout" error.
        ///
        /// This is crucial during navigation activities (like clicking a link where the destination page takes a long time to fully load). If the navigation takes longer than this timeout, WebDriver will terminate the operation and return a `timeout` error.
        ///
        /// `nil` leaves the timeout unchanged. Zero means the operation times out immediately.
        ///
        /// - Important: Must not be negative.
        public var pageLoad: Duration?
        
        /// The maximum time that WebDriver should wait when searching for elements.
        ///
        /// If an element is not immediately visible or available, WebDriver will keep retrying the find operation for the duration specified by the implicit timeout. After exceeding this time, if the element is still not found, only then it will throw a `no such element` error.
        ///
        /// `nil` leaves the timeout unchanged. Zero means the operation times out immediately.
        ///
        /// - Important: Must not be negative.
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
        
        /// Encodes the timeouts that are set, in milliseconds, as WebDriver expects them.
        ///
        /// - Throws: ``InvalidValue`` when a timeout is negative.
        public func encode() throws(InvalidValue) -> [String : Any] {
            var results: [String : Any] = [:]
            for (name, duration) in [("script", self.script), ("pageLoad", self.pageLoad), ("implicit", self.implicit)] {
                guard let duration else { continue }
                guard duration >= .zero else { throw InvalidValue(name: name, duration: duration) }
                results[name] = Int((duration / .milliseconds(1)).rounded())
            }
            return results
        }


        /// Decodes the timeouts reported by the server.
        ///
        /// A `null` script timeout, which means no limit, is decoded as `nil`.
        init(parser: JSONParser) throws {
            let value = try parser.decode(JSONParser.self, forKey: "value")
            self.script = try value.decodeIfPresent(Double.self, forKey: "script").map { .milliseconds($0) }
            self.pageLoad = try value.decodeIfPresent(Double.self, forKey: "pageLoad").map { .milliseconds($0) }
            self.implicit = try value.decodeIfPresent(Double.self, forKey: "implicit").map { .milliseconds($0) }
        }
        
        public init(script: Duration? = nil, pageLoad: Duration? = nil, implicit: Duration? = nil) {
            self.script = script
            self.pageLoad = pageLoad
            self.implicit = implicit
        }


        /// A timeout that cannot be sent, as it is negative.
        public struct InvalidValue: GenericError {

            /// The name of the timeout, such as `pageLoad`.
            public let name: String

            public let duration: Duration

            public var message: String {
                "The \(self.name) timeout must not be negative, but is \(self.duration)."
            }
        }

    }
}


extension Session {
    
    public var timeout: Timeout {
        get async throws {
            let (data, _) = try await self.data(.get, "session/\(id)/timeouts", data: nil, context: .unavailable, origin: .session(self), invoker: #function)
            return try Timeout(parser: JSONParser(data: data))
        }
    }
    
    public func set(timeout: Timeout, fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function) async throws {
        let _ = try await self.data(.post, "session/\(id)/timeouts", json: timeout.encode(),
                                    context: SwiftContext(fileID: fileID, line: line, function: function),
                                    origin: .session(self),
                                    invoker: #function)
    }
    
}
