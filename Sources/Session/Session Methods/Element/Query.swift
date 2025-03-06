//
//  Query.swift
//  WebDriver
//
//  Created by Vaida on 3/6/25.
//


extension Session.Window.Element {
    
    /// The query formed by locator, used for transmitting the query to backend.
    public struct Query: Equatable {
        
        let locator: Locator
        
        let value: String
        
        enum Locator: String, CustomStringConvertible, Equatable {
            case css
            case linkText
            case partialLinkText
            case tagName
            case xpath
            
            var description: String {
                ".\(self.rawValue)"
            }
        }
    }
    
}
