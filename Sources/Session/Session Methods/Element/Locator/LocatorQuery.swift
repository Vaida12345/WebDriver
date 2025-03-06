//
//  LocatorQuery.swift
//  WebDriver
//
//  Created by Vaida on 3/6/25.
//


extension Session.Window.Element {
    
    /// A locator.
    public protocol LocatorQuery {
        
        func makeQuery() -> _Query
        
    }
    
}
