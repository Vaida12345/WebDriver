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
        public let expiry: Date
        
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
        public let sameSite: CrossSiteRequestBehavior
        
        
        func makeJSON() -> [String : Any] {
            [
                "name": name,
                "domain": domain,
                "secure": secure,
                "httpOnly": httpOnly,
                "value": value,
                "path": path,
                "sameSite": sameSite.rawValue
            ]
        }
        
        
        init(parser: JSONParser) throws {
            self.domain = try parser.decode(String.self, forKey: "domain")
            self.secure = try parser.decode(Bool.self, forKey: "secure")
            self.expiry = try Date(timeIntervalSince1970: parser.decode(Double.self, forKey: "expiry"))
            self.httpOnly = try parser.decode(Bool.self, forKey: "httpOnly")
            self.value = try parser.decode(String.self, forKey: "value")
            self.path = try parser.decode(String.self, forKey: "path")
            self.sameSite = try CrossSiteRequestBehavior(rawValue: parser.decode(String.self, forKey: "sameSite"))!
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
