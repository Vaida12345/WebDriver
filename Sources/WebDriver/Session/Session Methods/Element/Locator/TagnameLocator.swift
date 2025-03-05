//
//  TagnameLocator.swift
//  WebDriver
//
//  Created by Vaida on 3/6/25.
//

internal extension Element {
    
    struct TagnameLocator: Locator {
        
        public static func == (_ lhs: Self, _ rhs: String) -> _Query {
            _Query.css_selector("#\(rhs)")
        }
        
        typealias Value = String
        
    }
    
}
