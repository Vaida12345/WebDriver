//
//  BooleanQuery.swift
//  WebDriver
//
//  Created by Vaida on 3/6/25.
//


public protocol LocatorQuery: CustomStringConvertible {

    func makeQuery() -> Session.Window.Element.Query

    var containsTag: Bool { get }

    var cssDescription: String? { get }

    /// The query as an XPath 1.0 boolean expression about the context node, such as `self::div` or `@id="a"`.
    ///
    /// Unlike `description`, which may be a location path such as `//div[…]`, this is always a predicate. It is used wherever a query is nested inside another expression, such as `not(…)`, or the predicates of ``Session/Window/Element/LocatorProxy/has(_:)``.
    var xpathPredicate: String { get }

}


/// Matches elements that satisfy both `lhs` and `rhs`.
public func && (lhs: any LocatorQuery, rhs: any LocatorQuery) -> any LocatorQuery {
    let lhs = expandLinkText(lhs)
    let rhs = expandLinkText(rhs)

    // special case
    if let lhs = lhs as? DisjunctionQuery, lhs.containsTag {
        // need to push in the AND
        // (a OR b) AND c => (a AND c) or (b AND c)
        // `&&` rather than `ConjunctionQuery`, so that each arm is flattened, and distributed again if `rhs` is also a disjunction.
        return DisjunctionQuery(body: lhs.body.map({ $0 && rhs }))
    } else if let rhs = rhs as? DisjunctionQuery, rhs.containsTag {
        // need to push in the AND
        // (a OR b) AND c => (a AND c) or (b AND c)
        return DisjunctionQuery(body: rhs.body.map({ lhs && $0 }))
    }
    
    if let lhs = lhs as? ConjunctionQuery, let rhs = rhs as? ConjunctionQuery {
        return ConjunctionQuery(body: lhs.body + rhs.body)
    } else if let lhs = lhs as? ConjunctionQuery {
        return ConjunctionQuery(body: lhs.body + [rhs])
    } else if let rhs = rhs as? ConjunctionQuery {
        return ConjunctionQuery(body: [lhs] + rhs.body)
    } else {
        return ConjunctionQuery(body: [lhs, rhs])
    }
}

/// Matches elements that satisfy `lhs`, `rhs`, or both.
public func || (lhs: any LocatorQuery, rhs: any LocatorQuery) -> any LocatorQuery {
    let lhs = expandLinkText(lhs)
    let rhs = expandLinkText(rhs)

    if let lhs = lhs as? DisjunctionQuery, let rhs = rhs as? DisjunctionQuery {
        return DisjunctionQuery(body: lhs.body + rhs.body)
    } else if let lhs = lhs as? DisjunctionQuery {
        return DisjunctionQuery(body: lhs.body + [rhs])
    } else if let rhs = rhs as? DisjunctionQuery {
        return DisjunctionQuery(body: [lhs] + rhs.body)
    } else {
        return DisjunctionQuery(body: [lhs, rhs])
    }
}

/// Matches elements that do not satisfy `query`.
///
/// Tags can be negated, for example, `!($0.tag == "div")` becomes `not(self::div)`.
public prefix func !(query: any LocatorQuery) -> any LocatorQuery {
    NegateQuery(body: expandLinkText(query))
}

//case and([LocatorQuery])
//case or([LocatorQuery])
//case not(LocatorQuery)
//case attribute(AttributeLocatorQuery)
//case xpath(XPathQuery)
//case tag(TagQuery)
