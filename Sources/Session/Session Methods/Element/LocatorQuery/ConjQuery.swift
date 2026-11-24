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
    /// A tag repeated with the same name, as in `$0.tag == "a" && $0.hrefText == "Docs"`, counts once.
    ///
    /// - Precondition: The body contains at most one distinct tag, as an element cannot have two tag names.
    func splitTag() -> (tag: TagQuery?, rest: [any LocatorQuery]) {
        var rest = body
        let tag = rest.firstIndex(where: { $0 is TagQuery }).map({ rest.remove(at: $0) }) as? TagQuery
        if let tag {
            rest.removeAll(where: { ($0 as? TagQuery)?.value == tag.value })
        }
        precondition(!rest.contains(where: { $0 is TagQuery }), "An element cannot have two tag names. The query itself is `false`.")
        return (tag, rest)
    }

    var cssDescription: String? {
        let (tag, body) = self.splitTag()

        // A CSS selector list cannot be nested in a compound selector: `div` with `[id="a"], [id="b"]` would give `div[id="a"], [id="b"]`.
        guard !body.contains(where: { $0 is DisjunctionQuery }) else { return nil }

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
        // Predicates, not `description`, so that a nested location path such as `//a[…]` is never put inside `[…]`.
        let descriptions = body.map(\.xpathPredicate)

        if let tag = tag?.value {
            // An empty predicate, `[]`, is not valid XPath.
            guard !descriptions.isEmpty else { return "//\(tag)" }
            return "//\(tag)[" + descriptions.joined(separator: " and ") + "]"
        } else {
            return "(" + descriptions.joined(separator: " and ") + ")"
        }
    }

    var xpathPredicate: String {
        "(" + body.map(\.xpathPredicate).joined(separator: " and ") + ")"
    }

}
