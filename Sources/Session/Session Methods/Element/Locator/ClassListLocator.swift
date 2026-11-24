//
//  ClassListLocator.swift
//  WebDriver
//
//  Created by Claude on 11/24/26.
//
//  A locator that treats the `class` attribute as a list of class names, for whole-word class matching.
//


extension Session.Window.Element {

    /// A locator for the element's class list.
    ///
    /// Unlike `$0.class`, which treats the `class` attribute as a single string, this treats it as a whitespace-separated list of class names, like `classList` in JavaScript.
    public struct ClassListLocator: Locator, Sendable {

        /// Matches elements that have `className` as one of their classes.
        ///
        /// For example, `contains("btn")` matches `class="btn primary"`, but not `class="btn-primary"`. In comparison, `$0.class.contains("btn")` is a substring search that matches both.
        ///
        /// - Parameter className: A single class name, without whitespace.
        public func contains(_ className: String) -> any LocatorQuery {
            AttributeQuery(locator: AttributeLocator(name: "class"), operation: .containsWord, value: className)
        }

        /// Matches elements that have all of `classNames` as their classes, in any order.
        ///
        /// This is equivalent to joining ``contains(_:)`` for each class name using `&&`.
        ///
        /// - Parameter classNames: The class names, each without whitespace.
        ///
        /// - Precondition: `classNames` is not empty.
        public func contains(all classNames: [String]) -> any LocatorQuery {
            precondition(!classNames.isEmpty, "At least one class name is required.")
            guard classNames.count > 1 else { return self.contains(classNames[0]) }
            return ConjunctionQuery(body: classNames.map(self.contains))
        }

    }

}
