//
//  LinkTextLocator.swift
//  WebDriver
//
//  Created by Vaida on 3/6/25.
//


extension Session.Window.Element {
    
    /// A CSS attribute locator.
    public struct LinkTextLocator: Locator {
        
        public func contains(_ other: String) -> Query {
            Query(locator: .partialLinkText, value: other)
        }
        
        public static func == (_ lhs: Self, _ rhs: String) -> Query {
            Query(locator: .linkText, value: rhs)
        }
        
    }
    
}
