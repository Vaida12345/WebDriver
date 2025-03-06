//
//  XPathLocator.swift
//  WebDriver
//
//  Created by Vaida on 3/6/25.
//

extension Session.Window.Element {
    
    /// An XPath locator.
    public struct XPathLocator: Locator {
        
        let attribute: XPathQuery.Attribute.Attribute
        
        
        public func contains(_ string: String) -> XPathQuery {
            XPathQuery(operation: .contains, attribute: self.attribute, value: string)
        }
        
        public func hasPrefix(_ string: String) -> XPathQuery {
            XPathQuery(operation: .hasPrefix, attribute: self.attribute, value: string)
        }
        
        public func hasSuffix(_ string: String) -> XPathQuery {
            XPathQuery(operation: .hasSuffix, attribute: self.attribute, value: string)
        }
        
        public static func == (_ lhs: Self, _ rhs: String) -> XPathQuery {
            XPathQuery(operation: .equals, attribute: lhs.attribute, value: rhs)
        }
        
        public static func != (_ lhs: Self, _ rhs: String) -> XPathQuery {
            XPathQuery(operation: .notEquals, attribute: lhs.attribute, value: rhs)
        }
        
    }
    
}
