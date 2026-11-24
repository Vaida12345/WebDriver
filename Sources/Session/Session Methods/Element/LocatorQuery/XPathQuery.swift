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
    /// Whether ASCII letters are compared case-insensitively. Ignored by operations that do not compare strings, see ``Operation/supportsCaseFolding``.
    let caseInsensitive: Bool
    /// Which element the attribute is evaluated on.
    let scope: Scope


    func makeQuery() -> Element.Query {
        .init(locator: .xpath, value: "//*[\(self.description)]")
    }

    var containsTag: Bool {
        false
    }

    var cssDescription: String? {
        nil
    }

    var xpathPredicate: String {
        self.description
    }


    /// The XPath 1.0 predicate expression.
    ///
    /// Only XPath 1.0 functions are used, as browsers do not implement XPath 2.0. In particular, `hasSuffix` is expressed using `substring` and `string-length` instead of `ends-with`, and case-insensitive matching uses `translate` instead of `lower-case`.
    public var description: String {
        let predicate = self.predicate

        switch scope {
        case .element:
            return predicate
        case .label:
            let labelable = XPathQuery.labelableTags.map { "self::\($0)" }.joined(separator: " or ")
            return "(@id = //label[\(predicate)]/@for or (ancestor::label[\(predicate)] and (\(labelable))))"
        }
    }

    /// The comparison of the attribute against the value, evaluated on the context node.
    private var predicate: String {
        var subject = switch attribute {
        case .property(let name): "@\(name)"
        case .function(let name): "\(name)()"
        case .expression(let expression): expression
        }
        var value = self.value

        if caseInsensitive && operation.supportsCaseFolding {
            subject = "translate(\(subject), \"\(XPathQuery.uppercase)\", \"\(XPathQuery.lowercase)\")"
            value = XPathQuery.asciiLowercased(value)
        }
        let literal = XPathQuery.literal(value)

        switch operation {
        case .contains:
            return "contains(\(subject), \(literal))"
        case .equals:
            return "\(subject)=\(literal)"
        case .notEquals:
            return "\(subject) != \(literal)"
        case .hasPrefix:
            return "starts-with(\(subject), \(literal))"
        case .hasSuffix:
            return "substring(\(subject), string-length(\(subject)) - string-length(\(literal)) + 1)=\(literal)"
        case .containsWord:
            return "contains(concat(\" \", normalize-space(\(subject)), \" \"), \(XPathQuery.literal(" \(value) ")))"
        case .exists:
            return subject
        case .isEmpty:
            return "normalize-space(\(subject))=\"\""
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

    /// The elements that can be associated with a `<label>`, per the HTML specification.
    static let labelableTags = ["button", "input", "meter", "output", "progress", "select", "textarea"]

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
        /// The attribute is present, regardless of its value. The value is ignored.
        case exists
        /// The attribute is empty or only contains whitespace. The value is ignored.
        case isEmpty

        /// Whether `caseInsensitive` applies to this operation.
        var supportsCaseFolding: Bool {
            switch self {
            case .contains, .equals, .notEquals, .hasPrefix, .hasSuffix: true
            case .containsWord, .exists, .isEmpty: false
            }
        }
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

    /// Which element the attribute is evaluated on.
    enum Scope {
        /// The element itself.
        case element
        /// The `<label>` associated with the element, either by its `for` attribute, or by wrapping the element.
        case label
    }

    /// Creates a query that compares `attribute` against `value` using `operation`.
    ///
    /// - Parameters:
    ///   - caseInsensitive: Whether ASCII letters are compared case-insensitively.
    ///   - scope: Which element the attribute is evaluated on.
    init(operation: Operation, attribute: Attribute, value: String, caseInsensitive: Bool = false, scope: Scope = .element) {
        self.operation = operation
        self.attribute = attribute
        self.value = value
        self.caseInsensitive = caseInsensitive
        self.scope = scope
    }

}
