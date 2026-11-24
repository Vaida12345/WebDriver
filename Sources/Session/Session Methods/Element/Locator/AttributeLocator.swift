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
    ///
    /// Case-insensitive matching uses the CSS `i` flag. When the query falls back to XPath, only ASCII letters are folded, as XPath 1.0 has no `lower-case()`.
    public struct AttributeLocator: Locator, Sendable {

        /// The attribute name, such as `id` or `aria-label`.
        let name: String

        /// Creates a locator for the attribute with the given name.
        init(name: String) {
            self.name = name
        }


        /// Matches elements that have this attribute, regardless of its value.
        ///
        /// This is useful for boolean attributes, such as `$0.disabled.exists`, which matches both `<button disabled>` and `<button disabled="disabled">`.
        public var exists: any LocatorQuery {
            AttributeQuery(locator: self, operation: .exists)
        }

        /// Matches elements whose attribute equals `value`.
        ///
        /// - Parameters:
        ///   - value: The value to compare against.
        ///   - caseInsensitive: Whether to ignore case.
        public func equals(_ value: String, caseInsensitive: Bool = false) -> any LocatorQuery {
            AttributeQuery(locator: self, operation: .equals, value: value, caseInsensitive: caseInsensitive)
        }

        /// Matches elements whose attribute contains `value` as a substring.
        ///
        /// - Parameters:
        ///   - value: The substring to search for.
        ///   - caseInsensitive: Whether to ignore case.
        public func contains(_ value: String, caseInsensitive: Bool = false) -> any LocatorQuery {
            AttributeQuery(locator: self, operation: .contains, value: value, caseInsensitive: caseInsensitive)
        }

        /// Matches elements whose attribute starts with `prefix`.
        ///
        /// - Parameters:
        ///   - prefix: The prefix to search for.
        ///   - caseInsensitive: Whether to ignore case.
        public func hasPrefix(_ prefix: String, caseInsensitive: Bool = false) -> any LocatorQuery {
            AttributeQuery(locator: self, operation: .hasPrefix, value: prefix, caseInsensitive: caseInsensitive)
        }

        /// Matches elements whose attribute ends with `suffix`.
        ///
        /// - Parameters:
        ///   - suffix: The suffix to search for.
        ///   - caseInsensitive: Whether to ignore case.
        public func hasSuffix(_ suffix: String, caseInsensitive: Bool = false) -> any LocatorQuery {
            AttributeQuery(locator: self, operation: .hasSuffix, value: suffix, caseInsensitive: caseInsensitive)
        }

        /// Matches elements whose attribute is exactly `rhs`.
        public static func == (_ lhs: AttributeLocator, _ rhs: String) -> any LocatorQuery {
            lhs.equals(rhs)
        }

        /// Matches elements whose attribute is present and not `rhs`.
        public static func != (_ lhs: AttributeLocator, _ rhs: String) -> any LocatorQuery {
            AttributeQuery(locator: lhs, operation: .notEquals, value: rhs)
        }

    }

}
