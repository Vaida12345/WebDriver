//
//  LinkTextQuery.swift
//  WebDriver
//
//  Created by Claude on 11/24/26.
//
//  A link text query that uses the native WebDriver link text strategies on its own, and expands to XPath when combined with other queries.
//


/// Matches `<a>` elements by their text.
///
/// On its own, this uses the native `link text` or `partial link text` strategies. When combined using `&&`, `||`, or `!`, it is replaced by ``expanded``, an equivalent XPath query.
struct LinkTextQuery: LocatorQuery {

    /// The text to match.
    let value: String

    /// Whether the link text only needs to contain ``value``, rather than equal it.
    let isPartial: Bool

    /// The equivalent query, `<a>` elements whose whitespace-normalized text matches ``value``.
    var expanded: ConjunctionQuery {
        ConjunctionQuery(body: [
            TagQuery(value: "a"),
            XPathQuery(operation: isPartial ? .contains : .equals, attribute: .expression("normalize-space(.)"), value: value)
        ])
    }

    func makeQuery() -> Element.Query {
        .init(locator: isPartial ? .partialLinkText : .linkText, value: value)
    }

    var containsTag: Bool {
        true
    }

    var cssDescription: String? {
        nil
    }

    var description: String {
        expanded.description
    }

    var xpathPredicate: String {
        expanded.xpathPredicate
    }

}


/// Replaces a ``LinkTextQuery`` with its XPath equivalent, so that it can be combined with other queries. Other queries are returned as is.
func expandLinkText(_ query: any LocatorQuery) -> any LocatorQuery {
    (query as? LinkTextQuery)?.expanded ?? query
}
