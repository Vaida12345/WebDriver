//
//  LocatorQuery.swift
//  WebDriver
//
//  Created by Vaida on 3/6/25.
//


/// A comparison on an attribute, rendered as a CSS attribute selector when possible, and as XPath otherwise.
struct AttributeQuery: LocatorQuery {

    let locator: Element.AttributeLocator
    let operation: XPathQuery.Operation
    let value: String
    let caseInsensitive: Bool

    /// Creates a query that compares the attribute against `value` using `operation`.
    init(locator: Element.AttributeLocator, operation: XPathQuery.Operation, value: String = "", caseInsensitive: Bool = false) {
        self.locator = locator
        self.operation = operation
        self.value = value
        self.caseInsensitive = caseInsensitive
    }

    func makeQuery() -> Element.Query {
        if let cssDescription {
            return .init(locator: .css, value: cssDescription)
        } else {
            return .init(locator: .xpath, value: "//*[\(self.description)]")
        }
    }

    /// The equivalent XPath query, used when CSS cannot express it, or when combined with queries that CSS cannot express.
    func makeXPathQuery() -> XPathQuery {
        XPathQuery(operation: operation, attribute: .property(locator.name), value: value, caseInsensitive: caseInsensitive)
    }

    var description: String {
        self.makeXPathQuery().description
    }

    var xpathPredicate: String {
        self.description
    }

    var containsTag: Bool {
        false
    }

    /// The CSS attribute selector, with the value escaped as a CSS string, or `nil` if CSS cannot express the operation.
    var cssDescription: String? {
        let symbol: String
        switch operation {
        case .equals: symbol = "="
        case .contains: symbol = "*="
        case .hasPrefix: symbol = "^="
        case .hasSuffix: symbol = "$="
        case .containsWord: symbol = "~="
        case .exists: return "[\(locator.name)]"
        case .notEquals, .isEmpty: return nil
        }

        let flag = caseInsensitive && operation.supportsCaseFolding ? " i" : ""
        return "[\(locator.name)\(symbol)\(AttributeQuery.literal(value))\(flag)]"
    }

    /// Returns `string` as a double-quoted CSS string literal.
    ///
    /// Backslashes and double quotes are escaped with a backslash, and line breaks are written as the escape sequences `\a ` and `\d `, as CSS strings cannot contain them directly.
    static func literal(_ string: String) -> String {
        var result = "\""
        for scalar in string.unicodeScalars {
            switch scalar {
            case "\\": result += "\\\\"
            case "\"": result += "\\\""
            case "\n": result += "\\a "
            case "\r": result += "\\d "
            default: result.unicodeScalars.append(scalar)
            }
        }
        return result + "\""
    }
}
