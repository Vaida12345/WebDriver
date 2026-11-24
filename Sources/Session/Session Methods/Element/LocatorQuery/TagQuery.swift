//
//  TagQuery.swift
//  WebDriver
//
//  Created by Vaida on 3/6/25.
//


struct TagQuery: LocatorQuery {
    
    let value: String
    
    
    func makeQuery() -> Element.Query {
        .init(locator: .tagName, value: self.value)
    }
    
    var description: String {
        "//\(self.value)"
    }
    
    var containsTag: Bool {
        true
    }
    
    var cssDescription: String? {
        nil
    }

    /// The tag as a test on the context node, `self::tag`.
    var xpathPredicate: String {
        "self::\(self.value)"
    }
    
}
