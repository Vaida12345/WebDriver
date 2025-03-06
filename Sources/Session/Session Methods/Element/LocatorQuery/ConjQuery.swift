//
//  ConjQuery.swift
//  WebDriver
//
//  Created by Vaida on 3/6/25.
//


struct ConjunctionQuery: LocatorQuery {
    
    let body: [any LocatorQuery]
    
    var cssDescription: String? {
        // find the tag
        var body = body
        let tag = body.firstIndex(where: { $0 is TagQuery }).map({ body.remove(at: $0) }) as? TagQuery
        precondition(!body.contains(where: { $0 is TagQuery }), "An element cannot have two tag names. The query itself is `false`.")
        
        let descriptions = body.map(\.cssDescription)
        let compact = descriptions.compacted()
        guard descriptions.count == compact.count else { return nil }
        
        var result = tag?.value ?? ""
        for i in compact {
            result += i
        }
        return result
    }
    
    func makeQuery() -> Element.Query {
        if let cssDescription {
            return .init(locator: .css, value: cssDescription)
        } else {
            let description = self.description
            return .init(locator: .xpath, value: description.hasPrefix("//") ? description : "//*[\(description)]")
        }
    }
    
    var containsTag: Bool {
        self.body.contains(where: \.containsTag)
    }
    
    var description: String {
        // find the tag
        var body = body
        let tag = body.firstIndex(where: { $0 is TagQuery }).map({ body.remove(at: $0) }) as? TagQuery
        precondition(!body.contains(where: { $0 is TagQuery }), "An element cannot have two tag names. The query itself is `false`.")
        
        let descriptions = body.map(\.description)
        
        if let tag = tag?.value {
            return "//\(tag)[" + descriptions.joined(separator: " and ") + "]"
        } else {
            return "(" + descriptions.joined(separator: " and ") + ")"
        }
    }
    
}
