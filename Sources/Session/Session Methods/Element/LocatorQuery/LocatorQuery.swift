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
    
}


public func && (lhs: any LocatorQuery, rhs: any LocatorQuery) -> any LocatorQuery {
    // special case
    if let lhs = lhs as? DisjunctionQuery, lhs.containsTag {
        // need to push in the AND
        // (a OR b) AND c => (a AND c) or (b AND c)
        return DisjunctionQuery(body: lhs.body.map({ ConjunctionQuery(body: [$0, rhs]) }))
    } else if let rhs = rhs as? DisjunctionQuery, rhs.containsTag {
        // need to push in the AND
        // (a OR b) AND c => (a AND c) or (b AND c)
        return DisjunctionQuery(body: rhs.body.map({ ConjunctionQuery(body: [$0, lhs]) }))
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

public func || (lhs: any LocatorQuery, rhs: any LocatorQuery) -> any LocatorQuery {
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

public prefix func !(query: any LocatorQuery) -> any LocatorQuery {
    NegateQuery(body: query)
}

//case and([LocatorQuery])
//case or([LocatorQuery])
//case not(LocatorQuery)
//case attribute(AttributeLocatorQuery)
//case xpath(XPathQuery)
//case tag(TagQuery)
