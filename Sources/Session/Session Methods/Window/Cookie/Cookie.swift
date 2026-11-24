//
//  Cookie.swift
//  WebDriver
//
//  Created by Vaida on 3/7/25.
//

import Foundation
import Essentials
import JSONParser


extension Session.Window {
    
    /// Represents an HTTP cookie in WebDriver.
    public struct Cookie: Sendable {
        
        /// The name of the cookie.
        ///
        /// Must be unique for the specified domain.
        public let name: String
        
        /// The domain associated with the cookie.
        ///
        /// The cookie is sent only to requests matching this domain.
        public let domain: String
        
        /// Indicates whether the cookie is marked as `Secure`.
        ///
        /// Secure cookies are only sent over HTTPS connections.
        public let secure: Bool
        
        /// The expiration date of the cookie.
        ///
        /// After this date, the cookie is no longer valid.
        public let expiry: Date?
        
        /// Indicates whether the cookie is marked as `HttpOnly`.
        ///
        /// HttpOnly cookies cannot be accessed via JavaScript (only sent with HTTP requests).
        public let httpOnly: Bool
        
        /// The value stored in the cookie.
        ///
        /// This is the actual data associated with the cookie name.
        public let value: String
        
        /// The path associated with the cookie.
        ///
        /// Defines the URL path for which the cookie is valid.
        public let path: String
        
        /// The SameSite policy of the cookie.
        ///
        /// Controlling cross-site request behavior.
        public let sameSite: CrossSiteRequestBehavior?
        
        
        func makeJSON() -> [String : Any] {
            var map: [String : Any] = [
                "name": name,
                "secure": secure,
                "httpOnly": httpOnly,
                "value": value,
                "path": path,
            ]

            if !domain.isEmpty {
                map["domain"] = domain
            }

            if let sameSite {
                map["sameSite"] = sameSite.rawValue
            }

            if let expiry {
                // The specification requires an integer number of seconds; drivers reject fractions.
                map["expiry"] = Int(expiry.timeIntervalSince1970.rounded(.down))
            }

            return map
        }


        /// Creates a cookie, which can be added using ``Session/Window/Cookies``.
        ///
        /// - Parameters:
        ///   - name: The name of the cookie.
        ///   - value: The value stored in the cookie.
        ///   - domain: The domain associated with the cookie. Pass an empty string to use the domain of the current page.
        ///   - path: The URL path for which the cookie is valid.
        ///   - secure: Whether the cookie is only sent over HTTPS connections.
        ///   - httpOnly: Whether the cookie cannot be accessed by JavaScript.
        ///   - expiry: The expiration date of the cookie, rounded down to whole seconds. Pass `nil` for a session cookie.
        ///   - sameSite: The SameSite policy of the cookie.
        public init(
            name: String,
            value: String,
            domain: String = "",
            path: String = "/",
            secure: Bool = false,
            httpOnly: Bool = false,
            expiry: Date? = nil,
            sameSite: CrossSiteRequestBehavior? = nil
        ) {
            self.name = name
            self.value = value
            self.domain = domain
            self.path = path
            self.secure = secure
            self.httpOnly = httpOnly
            self.expiry = expiry
            self.sameSite = sameSite
        }


        init(parser: JSONParser) throws {
            self.domain = try parser.decode(String.self, forKey: "domain")
            self.secure = try parser.decode(Bool.self, forKey: "secure")
            self.expiry = try parser.decodeIfPresent(Double.self, forKey: "expiry").map(Date.init(timeIntervalSince1970:))
            self.httpOnly = try parser.decode(Bool.self, forKey: "httpOnly")
            self.value = try parser.decode(String.self, forKey: "value")
            self.path = try parser.decode(String.self, forKey: "path")
            self.sameSite = try parser.decodeIfPresent(String.self, forKey: "sameSite").flatMap(CrossSiteRequestBehavior.init(rawValue:))
            self.name = try parser.decode(String.self, forKey: "name")
        }
        
        
        /// Defines the cross-site request behavior for cookies.
        ///
        /// This controls when the browser sends cookies in cross-site requests.
        public enum CrossSiteRequestBehavior: String, Sendable {
            
            /// Cookies are sent for same-site requests and top-level cross-site GET requests.
            ///
            /// This is the default behavior in most browsers.
            case lax = "Lax"
            
            /// Cookies are only sent for same-site requests.
            ///
            /// Cross-site requests will not include the cookie.
            case strict = "Strict"
            
            /// Cookies are sent in all requests, including cross-site.
            ///
            /// Requires the `Secure` flag (HTTPS).
            case none = "None"
            
        }
    }

    
}
