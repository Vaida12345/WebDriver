//
//  LocatorQuery.swift
//  WebDriver
//
//  Created by Vaida on 3/6/25.
//


extension Element {
    
    public indirect enum AttributeLocatorQuery: LocatorQuery {
        case exact(locator: AttributeLocator, value: String)
        case contains(locator: AttributeLocator, value: String)
        case hasPrefix(locator: AttributeLocator, value: String)
        case hasSuffix(locator: AttributeLocator, value: String)
        
        case and(tag: String?, [AttributeLocatorQuery])
        case or([AttributeLocatorQuery])
        
        
        var isCommonCSSAttribute: Bool {
            switch self {
            case .exact, .contains, .hasPrefix, .hasSuffix: true
            default: false
            }
        }
        
        var isCommonCSSAttributeAND: Bool {
            switch self {
            case .and: true
            default: false
            }
        }
        
        
        public func makeQuery() -> _Query {
            switch self {
            case let .exact(locator, value):
                return .css_selector("[\(locator)=\"\(value)\"]")
                
            case let .contains(locator, value):
                return .css_selector("[\(locator)*=\"\(value)\"]")
                
            case let .hasPrefix(locator, value):
                return .css_selector("[\(locator)^=\"\(value)\"]")
                
            case let .hasSuffix(locator, value):
                return .css_selector("[\(locator)$=\"\(value)\"]")
                
            case .and(let tag, let queries):
                if let tag, queries.isEmpty {
                    return .tag_name(tag)
                } else {
                    return .css_selector(queries.reduce(tag ?? "") {
                        switch $1.makeQuery() {
                        case .css_selector(let string):
                            $0 + string
                        default:
                            fatalError("Not common CSS attribute")
                        }
                    })
                }
                
            case .or(let queries):
                return .css_selector(queries.reduce("") {
                    switch $1.makeQuery() {
                    case .css_selector(let string):
                        $0 + ($0.isEmpty ? "" : ", ") + string
                    default:
                        fatalError("Not common CSS attribute")
                    }
                })
            }
        }
        
        public static func && (lhs: Self, rhs: Self) -> Self {
            switch (lhs, rhs) {
            case (.and(let tag, let lhs), .and(let tag2, let rhs)):
                precondition(tag == nil || tag2 == nil, "Two different tag names cannot be combined directly.")
                return .and(tag: tag ?? tag2, lhs + rhs)
            case (.and(let tag, let lhs), _):
                if rhs.isCommonCSSAttribute {
                    return .and(tag: tag, lhs + [rhs])
                }
            case (_, .and(let tag, let rhs)):
                if lhs.isCommonCSSAttribute {
                    return .and(tag: tag, rhs + [lhs])
                }
            default:
                if lhs.isCommonCSSAttribute && rhs.isCommonCSSAttribute {
                    return .and(tag: nil, [lhs, rhs])
                }
            }
            
            preconditionFailure("The query cannot be combined")
        }
        
        public static func || (lhs: Self, rhs: Self) -> Self {
            switch (lhs, rhs) {
            case (.or(let lhs), .or(let rhs)):
                return .or(lhs + rhs)
            case (.or(let lhs), _):
                if rhs.isCommonCSSAttribute {
                    return .or(lhs + [rhs])
                }
            case (_, .or(let rhs)):
                if lhs.isCommonCSSAttribute {
                    return .or(rhs + [lhs])
                }
            default:
                if (lhs.isCommonCSSAttribute || lhs.isCommonCSSAttributeAND) && (rhs.isCommonCSSAttribute || rhs.isCommonCSSAttributeAND) {
                    return .or([lhs, rhs])
                }
            }
            
            preconditionFailure("The query cannot be combined")
        }
    }
    
}
