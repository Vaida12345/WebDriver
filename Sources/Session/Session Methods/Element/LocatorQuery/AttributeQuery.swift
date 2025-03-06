//
//  LocatorQuery.swift
//  WebDriver
//
//  Created by Vaida on 3/6/25.
//


enum AttributeQuery: LocatorQuery {
    
    case exact(locator: Element.AttributeLocator, value: String)
    case contains(locator: Element.AttributeLocator, value: String)
    case hasPrefix(locator: Element.AttributeLocator, value: String)
    case hasSuffix(locator: Element.AttributeLocator, value: String)
    
    func makeQuery() -> Element.Query {
        return .init(locator: .css, value: self.cssDescription!)
    }
    
    func makeXPathQuery() -> XPathQuery {
        switch self {
        case .exact(let locator, let value):
            XPathQuery(operation: .equals, attribute: .property(locator.rawValue), value: value)
        case .contains(let locator, let value):
            XPathQuery(operation: .contains, attribute: .property(locator.rawValue), value: value)
        case .hasPrefix(let locator, let value):
            XPathQuery(operation: .hasPrefix, attribute: .property(locator.rawValue), value: value)
        case .hasSuffix(let locator, let value):
            XPathQuery(operation: .hasSuffix, attribute: .property(locator.rawValue), value: value)
        }
    }
    
    var description: String {
        self.makeXPathQuery().description
    }
    
    var containsTag: Bool {
        false
    }
    
    var cssDescription: String? {
        switch self {
        case let .exact(locator, value):
            return "[\(locator)=\"\(value)\"]"
            
        case let .contains(locator, value):
            return "[\(locator)*=\"\(value)\"]"
            
        case let .hasPrefix(locator, value):
            return "[\(locator)^=\"\(value)\"]"
            
        case let .hasSuffix(locator, value):
            return "[\(locator)$=\"\(value)\"]"
        }
    }
}
