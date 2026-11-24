//
//  ConjQuery.swift
//  WebDriver
//
//  Created by Vaida on 3/6/25.
//


struct ConjunctionQuery: LocatorQuery {

    let body: [any LocatorQuery]

    /// Separates the tag, if any, from the rest of the body.
    ///
    /// - Precondition: The body contains at most one tag, as an element cannot have two tag names.
    func splitTag() -> (tag: TagQuery?, rest: [any LocatorQuery]) {
        var rest = body
        let tag = rest.firstIndex(where: { $0 is TagQuery }).map({ rest.remove(at: $0) }) as? TagQuery
        precondition(!rest.contains(where: { $0 is TagQuery }), "An element cannot have two tag names. The query itself is `false`.")
        return (tag, rest)
    }

    var cssDescription: String? {
        let (tag, body) = self.splitTag()

        let descriptions = body.map(\.cssDescription)
        let compact = descriptions.compacted()
        guard descriptions.count == compact.count else { return nil }

        var result = tag?.value ?? ""
        for i in compact {
            result += i
        }
        return result
    }

    func makeQuery() -> Element.Query {
        if let cssDescription {
            return .init(locator: .css, value: cssDescription)
        } else {
            let description = self.description
            return .init(locator: .xpath, value: description.hasPrefix("//") ? description : "//*[\(description)]")
        }
    }

    var containsTag: Bool {
        self.body.contains(where: \.containsTag)
    }

    /// The XPath location path `//tag[…]` when the body has a tag, or a parenthesized predicate otherwise.
    var description: String {
        let (tag, body) = self.splitTag()
        let descriptions = body.map(\.description)

        if let tag = tag?.value {
            return "//\(tag)[" + descriptions.joined(separator: " and ") + "]"
        } else {
            return "(" + descriptions.joined(separator: " and ") + ")"
        }
    }

    var xpathPredicate: String {
        "(" + body.map(\.xpathPredicate).joined(separator: " and ") + ")"
    }

}
