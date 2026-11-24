//
//  LocatorQuery.swift
//  WebDriver
//
//  Created by Vaida on 3/6/25.
//


enum AttributeQuery: LocatorQuery {

    case exact(locator: Element.AttributeLocator, value: String)
    case contains(locator: Element.AttributeLocator, value: String, caseInsensitive: Bool)
    case hasPrefix(locator: Element.AttributeLocator, value: String)
    case hasSuffix(locator: Element.AttributeLocator, value: String)
    /// The attribute, as a whitespace-separated list, contains `value` as one of its words.
    case containsWord(locator: Element.AttributeLocator, value: String)

    func makeQuery() -> Element.Query {
        return .init(locator: .css, value: self.cssDescription!)
    }

    /// The equivalent XPath query, used when combined with queries that CSS cannot express.
    func makeXPathQuery() -> XPathQuery {
        switch self {
        case .exact(let locator, let value):
            XPathQuery(operation: .equals, attribute: .property(locator.name), value: value)
        case .contains(let locator, let value, let caseInsensitive):
            XPathQuery(operation: .contains, attribute: .property(locator.name), value: value, caseInsensitive: caseInsensitive)
        case .hasPrefix(let locator, let value):
            XPathQuery(operation: .hasPrefix, attribute: .property(locator.name), value: value)
        case .hasSuffix(let locator, let value):
            XPathQuery(operation: .hasSuffix, attribute: .property(locator.name), value: value)
        case .containsWord(let locator, let value):
            XPathQuery(operation: .containsWord, attribute: .property(locator.name), value: value)
        }
    }

    var description: String {
        self.makeXPathQuery().description
    }

    var containsTag: Bool {
        false
    }

    /// The CSS attribute selector, with the value escaped as a CSS string.
    var cssDescription: String? {
        switch self {
        case let .exact(locator, value):
            return "[\(locator.name)=\(AttributeQuery.literal(value))]"

        case let .contains(locator, value, caseInsensitive):
            return "[\(locator.name)*=\(AttributeQuery.literal(value))\(caseInsensitive ? " i" : "")]"

        case let .hasPrefix(locator, value):
            return "[\(locator.name)^=\(AttributeQuery.literal(value))]"

        case let .hasSuffix(locator, value):
            return "[\(locator.name)$=\(AttributeQuery.literal(value))]"

        case let .containsWord(locator, value):
            return "[\(locator.name)~=\(AttributeQuery.literal(value))]"
        }
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
