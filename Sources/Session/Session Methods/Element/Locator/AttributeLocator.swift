//
//  AttributeLocator.swift
//  WebDriver
//
//  Created by Vaida on 3/6/25.
//


extension Session.Window.Element {

    /// A CSS attribute locator.
    ///
    /// Obtain one from ``LocatorProxy``, such as `$0.title`, or `$0.attribute("data-testid")` for any other attribute.
    public struct AttributeLocator: Locator, Sendable {

        /// The attribute name, such as `id` or `aria-label`.
        let name: String

        /// Creates a locator for the attribute with the given name.
        init(name: String) {
            self.name = name
        }


        /// Matches elements whose attribute contains `value` as a substring.
        ///
        /// - Parameters:
        ///   - value: The substring to search for.
        ///   - caseInsensitive: Whether to ignore case. In CSS, this uses the `i` flag. When the query falls back to XPath, only ASCII letters are folded, as XPath 1.0 has no `lower-case()`.
        public func contains(_ value: String, caseInsensitive: Bool = false) -> any LocatorQuery {
            AttributeQuery.contains(locator: self, value: value, caseInsensitive: caseInsensitive)
        }

        /// Matches elements whose attribute starts with `prefix`.
        public func hasPrefix(_ prefix: String) -> any LocatorQuery {
            AttributeQuery.hasPrefix(locator: self, value: prefix)
        }

        /// Matches elements whose attribute ends with `suffix`.
        public func hasSuffix(_ suffix: String) -> any LocatorQuery {
            AttributeQuery.hasSuffix(locator: self, value: suffix)
        }

        /// Matches elements whose attribute is exactly `rhs`.
        public static func == (_ lhs: AttributeLocator, _ rhs: String) -> any LocatorQuery {
            AttributeQuery.exact(locator: lhs, value: rhs)
        }

        /// Matches elements whose attribute is not `rhs`.
        public static func != (_ lhs: AttributeLocator, _ rhs: String) -> any LocatorQuery {
            XPathQuery(operation: .notEquals, attribute: .property(lhs.name), value: rhs)
        }

    }

}
