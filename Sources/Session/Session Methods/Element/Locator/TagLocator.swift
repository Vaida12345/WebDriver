//
//  TagLocator.swift
//  WebDriver
//
//  Created by Vaida on 3/6/25.
//


extension Session.Window.Element {
    
    /// A CSS attribute locator.
    public struct TagLocator: Locator {
        
        /// Use equitable to form query.
        public static func == (_ lhs: TagLocator, _ rhs: HTMLTag) -> any LocatorQuery {
            TagQuery(value: rhs.rawValue)
        }

        /// Matches elements whose tag name is not `rhs`, using the XPath `not(self::tag)`.
        public static func != (_ lhs: TagLocator, _ rhs: HTMLTag) -> any LocatorQuery {
            NegateQuery(body: TagQuery(value: rhs.rawValue))
        }
        
    }
    
}
