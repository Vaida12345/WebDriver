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
            case css = "css selector"
            case linkText = "link text"
            case partialLinkText = "partial link text"
            case tagName = "tag name"
            case xpath = "xpath"
            
            var description: String {
                ".\(self.rawValue)"
            }
        }
        
        
        init(locator: Locator, value: String) {
            self.locator = locator
            self.value = value
        }
    }
    
}
