//
//  RelativeQuery.swift
//  WebDriver
//
//  Created by Claude on 11/24/26.
//
//  A query that matches elements by a related element, such as a descendant or the preceding sibling.
//


/// Matches elements that have a related element matching ``body``.
struct RelativeQuery: LocatorQuery {

    /// How the related element relates to the matched element.
    enum Relation {
        /// Any descendant of the element.
        case descendant
        /// The element's immediately preceding sibling element.
        case previousSibling
    }

    let relation: Relation

    /// The query the related element must satisfy.
    let body: any LocatorQuery


    func makeQuery() -> Element.Query {
        .init(locator: .xpath, value: "//*[\(self.description)]")
    }

    var containsTag: Bool {
        false
    }

    var cssDescription: String? {
        nil
    }

    var description: String {
        self.xpathPredicate
    }

    /// The relative location path, which is true when it selects any element.
    ///
    /// For descendants, a tag in the body becomes the node test, as in `descendant::button[…]`.
    var xpathPredicate: String {
        let body = expandLinkText(self.body)

        switch relation {
        case .descendant:
            if let tag = body as? TagQuery {
                return "descendant::\(tag.value)"
            }
            if let conjunction = body as? ConjunctionQuery {
                let (tag, rest) = conjunction.splitTag()
                if let tag {
                    // An empty predicate, `[]`, is not valid XPath.
                    guard !rest.isEmpty else { return "descendant::\(tag.value)" }
                    return "descendant::\(tag.value)[" + rest.map(\.xpathPredicate).joined(separator: " and ") + "]"
                }
            }
            return "descendant::*[\(body.xpathPredicate)]"

        case .previousSibling:
            return "preceding-sibling::*[1][\(body.xpathPredicate)]"
        }
    }

}
