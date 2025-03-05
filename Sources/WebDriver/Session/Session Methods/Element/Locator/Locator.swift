//
//  Locator.swift
//  WebDriver
//
//  Created by Vaida on 3/6/25.
//


extension Session.Window.Element {
    
    /// A locator.
    public protocol Locator<Value> {
        
        /// Creates the locator.
        init()
        
        /// Use equitable to form query.
        static func == (_ lhs: Self, _ rhs: Value) -> _Query
        
        /// The value to match against.
        associatedtype Value: Equatable
        
    }
    
}
