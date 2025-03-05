//
//  AttributeLocator.swift
//  WebDriver
//
//  Created by Vaida on 3/6/25.
//


extension Session.Window.Element {
    
    /// A CSS attribute locator.
    public enum AttributeLocator: String, Locator {
        
        case id
        case `class`
        case style
        case title
        case hidden
        case tabindex
        case type
        case value
        case placeholder
        case name
        case pattern
        case href
        case src
        case alt
        
        
        public func contains(_ value: String) -> AttributeLocatorQuery {
            .contains(locator: self, value: value)
        }
        
        public func hasPrefix(_ prefix: String) -> AttributeLocatorQuery {
            .hasPrefix(locator: self, value: prefix)
        }
        
        public func hasSuffix(_ suffix: String) -> AttributeLocatorQuery {
            .hasSuffix(locator: self, value: suffix)
        }
        
        /// Use equitable to form query.
        public static func == (_ lhs: Self, _ rhs: String) -> AttributeLocatorQuery {
            .exact(locator: lhs, value: rhs)
        }
        
    }
    
}
