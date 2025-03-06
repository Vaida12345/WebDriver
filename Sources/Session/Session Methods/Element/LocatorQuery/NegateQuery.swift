//
//  NegateQuery.swift
//  WebDriver
//
//  Created by Vaida on 3/6/25.
//


struct NegateQuery: LocatorQuery {
    
    let body: any LocatorQuery
    
    
    func makeQuery() -> Session.Window.Element.Query {
        .init(locator: .xpath, value: "//*[\(self.description)]")
    }
    
    
    var description: String {
        precondition(!self.containsTag, "Negating a tag is not supported.")
        return "not(\(self.body.description))"
    }
    
    var containsTag: Bool {
        self.body.containsTag
    }
    
    var cssDescription: String? {
        nil
    }
    
}
