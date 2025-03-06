//
//  LinkTextLocator.swift
//  WebDriver
//
//  Created by Vaida on 3/6/25.
//


extension Session.Window.Element {
    
    /// A CSS attribute locator.
    public struct LinkTextLocator: Locator {
        
        public func contains(_ other: String) -> _Query {
            .partial_link_text(other)
        }
        
        public static func == (_ lhs: Self, _ rhs: String) -> _Query {
            .link_text(rhs)
        }
        
    }
    
}
