//
//  DisjQuery.swift
//  WebDriver
//
//  Created by Vaida on 3/6/25.
//


struct DisjunctionQuery: LocatorQuery {
        
    let body: [any LocatorQuery]
    
    var cssDescription: String? {
        let descriptions = self.body.map(\.cssDescription)
        let compact = descriptions.compacted()
        guard descriptions.count == compact.count else { return nil }
        
        return compact.joined(separator: ", ")
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
        if self.containsTag {
            return body.map({
                let description = $0.description
                return description.hasPrefix("//") ? description : "//*[\(description)]"
            }).joined(separator: " | ")
        } else {
            return "(" + body.map(\.description).joined(separator: " or ") + ")"
        }
    }
    
}
