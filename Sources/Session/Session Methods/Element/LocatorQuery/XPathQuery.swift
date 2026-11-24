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
    /// Whether ASCII letters are compared case-insensitively. Only applies to ``Operation/contains``.
    let caseInsensitive: Bool


    func makeQuery() -> Element.Query {
        .init(locator: .xpath, value: "//*[\(self.description)]")
    }

    var containsTag: Bool {
        false
    }

    var cssDescription: String? {
        nil
    }


    /// The XPath 1.0 predicate expression.
    ///
    /// Only XPath 1.0 functions are used, as browsers do not implement XPath 2.0. In particular, `hasSuffix` is expressed using `substring` and `string-length` instead of `ends-with`, and case-insensitive matching uses `translate` instead of `lower-case`.
    public var description: String {
        let value = XPathQuery.literal(self.value)
        let attribute = switch attribute {
        case .property(let name): "@\(name)"
        case .function(let name): "\(name)()"
        case .expression(let expression): expression
        }

        switch operation {
        case .contains:
            if caseInsensitive {
                let folded = XPathQuery.literal(XPathQuery.asciiLowercased(self.value))
                return "contains(translate(\(attribute), \"\(XPathQuery.uppercase)\", \"\(XPathQuery.lowercase)\"), \(folded))"
            }
            return "contains(\(attribute), \(value))"
        case .equals:
            return "\(attribute)=\(value)"
        case .notEquals:
            return "\(attribute) != \(value)"
        case .hasPrefix:
            return "starts-with(\(attribute), \(value))"
        case .hasSuffix:
            return "substring(\(attribute), string-length(\(attribute)) - string-length(\(value)) + 1)=\(value)"
        case .containsWord:
            return "contains(concat(\" \", normalize-space(\(attribute)), \" \"), \(XPathQuery.literal(" \(self.value) ")))"
        }
    }

    /// Returns `string` as an XPath 1.0 string literal.
    ///
    /// XPath 1.0 has no escape sequences, so the delimiter is chosen based on the content: double quotes by default, single quotes when `string` contains a double quote, and `concat(…)` when it contains both.
    static func literal(_ string: String) -> String {
        guard string.contains("\"") else { return "\"\(string)\"" }
        guard string.contains("'") else { return "'\(string)'" }

        let parts = string.split(separator: "\"", omittingEmptySubsequences: false).map { "\"\($0)\"" }
        return "concat(" + parts.joined(separator: ", '\"', ") + ")"
    }

    /// The ASCII uppercase letters, used with `translate` for case folding.
    static let uppercase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

    /// The ASCII lowercase letters, used with `translate` for case folding.
    static let lowercase = "abcdefghijklmnopqrstuvwxyz"

    /// Lowercases ASCII letters only, matching what `translate(…, uppercase, lowercase)` does in the browser.
    static func asciiLowercased(_ string: String) -> String {
        String(String.UnicodeScalarView(string.unicodeScalars.map { scalar in
            ("A"..."Z").contains(scalar) ? Unicode.Scalar(scalar.value + 32)! : scalar
        }))
    }

    enum Operation {
        case contains
        case equals
        case notEquals
        case hasPrefix
        case hasSuffix
        /// The attribute, as a whitespace-separated list, contains the value as one of its words.
        case containsWord
    }

    /// The left-hand side of an XPath predicate.
    enum Attribute {
        /// An attribute of the element, rendered as `@name`.
        case property(String)
        /// A zero-argument XPath function, rendered as `name()`.
        case function(String)
        /// A raw XPath expression, rendered verbatim, such as `normalize-space(.)`.
        case expression(String)
    }

    /// Creates a query that compares `attribute` against `value` using `operation`.
    ///
    /// - Parameter caseInsensitive: Whether ASCII letters are compared case-insensitively. Only applies to ``Operation/contains``.
    init(operation: Operation, attribute: Attribute, value: String, caseInsensitive: Bool = false) {
        self.operation = operation
        self.attribute = attribute
        self.value = value
        self.caseInsensitive = caseInsensitive
    }

}
