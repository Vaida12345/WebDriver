//
//  XPathQuery.swift
//  WebDriver
//
//  Created by Vaida on 3/6/25.
//


struct XPathQuery: LocatorQuery, CustomStringConvertible {
    
    let operation: Operation
    let attribute: Attribute
    let value: String
    
    
    func makeQuery() -> Element.Query {
        .init(locator: .xpath, value: "//*[\(self.description)]")
    }
    
    var containsTag: Bool {
        false
    }
    
    var cssDescription: String? {
        nil
    }
    
    
    public var description: String {
        let attribute = switch attribute {
        case .property(let name): "@\(name)"
        case .function(let name): "\(name)()"
        }
        
        switch operation {
        case .contains:
            return "contains(\(attribute), \(value))"
        case .equals:
            return "\(attribute)=\(value)"
        case .notEquals:
            return "\(attribute) != \(value)"
        case .hasPrefix:
            return "starts-with(\(attribute), \(value))"
        case .hasSuffix:
            return "ends-with(\(attribute), \(value))"
        }
    }
    
    enum Operation {
        case contains
        case equals
        case notEquals
        case hasPrefix
        case hasSuffix
    }
    
    enum Attribute {
        case property(String)
        case function(String)
    }
    
    init(operation: Operation, attribute: Attribute, value: String) {
        self.operation = operation
        self.attribute = attribute
        self.value = value
    }
    
}
