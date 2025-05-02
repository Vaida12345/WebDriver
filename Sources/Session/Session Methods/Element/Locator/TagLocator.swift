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
        
    }
    
}
