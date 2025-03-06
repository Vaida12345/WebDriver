//
//  TagLocator.swift
//  WebDriver
//
//  Created by Vaida on 3/6/25.
//


extension Session.Window.Element {
    
    /// A CSS attribute locator.
    public enum TagLocator: String, Locator {
        case tag
        
        /// Use equitable to form query.
        public static func == (_ lhs: Self, _ rhs: String) -> AttributeLocatorQuery {
            .and(tag: rhs, [])
        }
        
    }
    
}
