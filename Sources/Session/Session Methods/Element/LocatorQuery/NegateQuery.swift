//
//  NegateQuery.swift
//  WebDriver
//
//  Created by Vaida on 3/6/25.
//


struct NegateQuery: LocatorQuery {

    let body: any LocatorQuery


    func makeQuery() -> Session.Window.Element.Query {
        .init(locator: .xpath, value: "//*[\(self.description)]")
    }

    /// The negated predicate of the body. Tags are expressed as `self::tag`, so they can be negated too.
    var description: String {
        "not(\(self.body.xpathPredicate))"
    }

    /// Always `false`: a negated tag does not name the tag of the element, so it is rendered within the predicate instead.
    var containsTag: Bool {
        false
    }

    var cssDescription: String? {
        nil
    }

    var xpathPredicate: String {
        self.description
    }

}
