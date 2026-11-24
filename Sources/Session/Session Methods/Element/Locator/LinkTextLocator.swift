//
//  LinkTextLocator.swift
//  WebDriver
//
//  Created by Vaida on 3/6/25.
//


extension Session.Window.Element {

    /// A locator for the text of `<a>` elements.
    ///
    /// On its own, it uses the native WebDriver link text strategies. Combined with other queries, it becomes the XPath `//a[normalize-space(.)=…]`.
    public struct LinkTextLocator: Locator {

        /// Matches links whose text contains `other`.
        public func contains(_ other: String) -> any LocatorQuery {
            LinkTextQuery(value: other, isPartial: true)
        }

        /// Matches links whose text is exactly `rhs`.
        public static func == (_ lhs: LinkTextLocator, _ rhs: String) -> any LocatorQuery {
            LinkTextQuery(value: rhs, isPartial: false)
        }

    }

}
