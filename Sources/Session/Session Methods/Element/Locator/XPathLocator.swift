//
//  XPathLocator.swift
//  WebDriver
//
//  Created by Vaida on 3/6/25.
//

extension Session.Window.Element {

    /// An XPath locator.
    ///
    /// Case-insensitive matching only folds ASCII letters, as XPath 1.0 has no `lower-case()`.
    public struct XPathLocator: Locator {

        let attribute: XPathQuery.Attribute

        /// Which element the attribute is evaluated on.
        let scope: XPathQuery.Scope

        /// Creates a locator for `attribute`, evaluated on the element given by `scope`.
        init(attribute: XPathQuery.Attribute, scope: XPathQuery.Scope = .element) {
            self.attribute = attribute
            self.scope = scope
        }


        /// Matches elements whose value is empty, or only contains whitespace.
        public var isEmpty: any LocatorQuery {
            XPathQuery(operation: .isEmpty, attribute: self.attribute, value: "", scope: self.scope)
        }

        /// Matches elements whose value equals `string`.
        ///
        /// - Parameters:
        ///   - string: The value to compare against.
        ///   - caseInsensitive: Whether to ignore case.
        public func equals(_ string: String, caseInsensitive: Bool = false) -> any LocatorQuery {
            XPathQuery(operation: .equals, attribute: self.attribute, value: string, caseInsensitive: caseInsensitive, scope: self.scope)
        }

        /// Matches elements whose value contains `string` as a substring.
        ///
        /// - Parameters:
        ///   - string: The substring to search for.
        ///   - caseInsensitive: Whether to ignore case.
        public func contains(_ string: String, caseInsensitive: Bool = false) -> any LocatorQuery {
            XPathQuery(operation: .contains, attribute: self.attribute, value: string, caseInsensitive: caseInsensitive, scope: self.scope)
        }

        /// Matches elements whose value starts with `string`.
        ///
        /// - Parameters:
        ///   - string: The prefix to search for.
        ///   - caseInsensitive: Whether to ignore case.
        public func hasPrefix(_ string: String, caseInsensitive: Bool = false) -> any LocatorQuery {
            XPathQuery(operation: .hasPrefix, attribute: self.attribute, value: string, caseInsensitive: caseInsensitive, scope: self.scope)
        }

        /// Matches elements whose value ends with `string`.
        ///
        /// - Parameters:
        ///   - string: The suffix to search for.
        ///   - caseInsensitive: Whether to ignore case.
        public func hasSuffix(_ string: String, caseInsensitive: Bool = false) -> any LocatorQuery {
            XPathQuery(operation: .hasSuffix, attribute: self.attribute, value: string, caseInsensitive: caseInsensitive, scope: self.scope)
        }

        /// Matches elements whose value is exactly `rhs`.
        public static func == (_ lhs: XPathLocator, _ rhs: String) -> any LocatorQuery {
            lhs.equals(rhs)
        }

        /// Matches elements whose value is not `rhs`.
        public static func != (_ lhs: XPathLocator, _ rhs: String) -> any LocatorQuery {
            XPathQuery(operation: .notEquals, attribute: lhs.attribute, value: rhs, scope: lhs.scope)
        }

    }

}
