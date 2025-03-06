//
//  XPathQuery.swift
//  WebDriver
//
//  Created by Vaida on 3/6/25.
//

extension Element {
    
    public struct XPathQuery: LocatorQuery {
        
        let tag: String?
        
        let attributes: LinkedAttribute
        
        
        public func makeQuery() -> Session.Window.Element._Query {
            var text = "//"
            if let tag = tag {
                text.write(tag)
            } else {
                text.write("*")
            }
            
            return .xpath(text + attributes.description)
        }
        
        
        indirect enum LinkedAttribute: CustomStringConvertible {
            case and(LinkedAttribute, LinkedAttribute)
            case or(LinkedAttribute, LinkedAttribute)
            case not(LinkedAttribute)
            case leaf(Attribute)
            
            var description: String {
                switch self {
                case .and(let lhs, let rhs):
                    "(\(lhs) and \(rhs))"
                case .or(let lhs, let rhs):
                    "(\(lhs) or \(rhs))"
                case .not(let attribute):
                    "not(\(attribute))"
                case .leaf(let attribute):
                    attribute.description
                }
            }
        }
        
        struct Attribute: CustomStringConvertible {
            let operation: Operation
            let attribute: Attribute
            let value: String
            
            
            var description: String {
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
        }
        
        
        public static func && (_ lhs: Self, _ rhs: Self) -> Self {
            precondition(lhs.tag == nil || rhs.tag == nil, "HTML does not support having two tags.")
            
            return XPathQuery(
                tag: lhs.tag ?? rhs.tag,
                attributes: .and(lhs.attributes, rhs.attributes)
            )
        }
        
        public static func || (_ lhs: Self, _ rhs: Self) -> Self {
            precondition(lhs.tag == nil || rhs.tag == nil, "XPath `or` with two tags (`or` on two separate XPath expressions) is not supported in this implementation.")
            return XPathQuery(
                tag: lhs.tag ?? rhs.tag,
                attributes: .or(lhs.attributes, rhs.attributes)
            )
        }
        
        public static prefix func !(_ other: Self) -> Self {
            return XPathQuery(
                tag: other.tag,
                attributes: .not(other.attributes)
            )
        }
        
        
        init(tag: String?, attributes: LinkedAttribute) {
            self.tag = tag
            self.attributes = attributes
        }
        
        init(operation: Attribute.Operation, attribute: Attribute.Attribute, value: String) {
            self.init(
                tag: nil,
                attributes: .leaf(.init(operation: operation, attribute: attribute, value: value))
            )
        }
        
    }
    
    
}
