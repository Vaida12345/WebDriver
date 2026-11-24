//
//  Shadow Content Search.swift
//  WebDriver
//
//  Created by Claude on 11/25/26.
//
//  Finders that also search the content of open shadow roots, using a bundled script.
//

import Foundation
import Essentials


extension Session.Window {

    /// Finds the first element in the document, or in the content of any open shadow root, nested or not.
    ///
    /// ```swift
    /// let buy = try await window.findElement(where: { $0.tag == "button" && $0.title == "Buy" }, includingShadowContent: true)
    /// ```
    ///
    /// The search visits elements in page order. The content of a shadow root comes right after its host element, before the host's own children.
    ///
    /// - Important: Only queries that compile to CSS selectors, tag names, or link text are supported, as XPath does not reach into shadow roots. A query matching text, for example, throws ``ShadowContentSearchError/unsupportedQuery(_:)``. Closed shadow roots and frames are not searched; use ``content(of:)`` for frames. To match a host and its shadow content together, find the host first, then search its ``Element/shadowRoot``.
    ///
    /// - Note: The search visits every element of the page, so it is slower than ``findElement(where:fileID:line:function:)``.
    ///
    /// - Parameters:
    ///   - predicate: The element to find.
    ///   - includingShadowContent: Whether to search the content of shadow roots. When `false`, this is the same as ``findElement(where:fileID:line:function:)``.
    ///
    /// - Throws: ``WebDriverError`` with ``WebDriverError/ErrorCode/no_such_element`` when nothing matches.
    ///
    /// > First Responder:
    /// > The first responder is switched to `self`.
    public func findElement(where predicate: @Sendable (Element.LocatorProxy) -> any LocatorQuery, includingShadowContent: Bool, fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function) async throws -> Element {
        try await self.findElement(where: { predicate($0).makeQuery() }, includingShadowContent: includingShadowContent, fileID: fileID, line: line, function: function)
    }

    /// Finds the first element in the document, or in the content of any open shadow root, nested or not.
    ///
    /// See ``findElement(where:includingShadowContent:fileID:line:function:)``.
    public func findElement(where predicate: @Sendable (Element.LocatorProxy) -> Element.Query, includingShadowContent: Bool, fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function) async throws -> Element {
        guard includingShadowContent else {
            return try await self.findElement(where: predicate, fileID: fileID, line: line, function: function)
        }
        let query = predicate(Element.LocatorProxy())
        guard let element = try await ShadowContentSearch.first(matching: query, in: self, root: nil, fileID: fileID, line: line, function: function) else {
            throw ShadowContentSearch.noSuchElement(query, window: self, context: SwiftContext(fileID: fileID, line: line, function: function))
        }
        return element
    }

    /// Finds the elements in the document, and in the content of all open shadow roots, nested or not.
    ///
    /// See ``findElement(where:includingShadowContent:fileID:line:function:)``.
    public func findElements(where predicate: @Sendable (Element.LocatorProxy) -> any LocatorQuery, includingShadowContent: Bool, fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function) async throws -> [Element] {
        try await self.findElements(where: { predicate($0).makeQuery() }, includingShadowContent: includingShadowContent, fileID: fileID, line: line, function: function)
    }

    /// Finds the elements in the document, and in the content of all open shadow roots, nested or not.
    ///
    /// See ``findElement(where:includingShadowContent:fileID:line:function:)``.
    public func findElements(where predicate: @Sendable (Element.LocatorProxy) -> Element.Query, includingShadowContent: Bool, fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function) async throws -> [Element] {
        guard includingShadowContent else {
            return try await self.findElements(where: predicate, fileID: fileID, line: line, function: function)
        }
        return try await ShadowContentSearch.all(matching: predicate(Element.LocatorProxy()), in: self, root: nil, fileID: fileID, line: line, function: function)
    }


    /// An error thrown by searches that include shadow content.
    public enum ShadowContentSearchError: GenericError {

        /// The query compiles to XPath, which does not reach into shadow roots.
        case unsupportedQuery(Element.Query)

        public var title: String? { "Unsupported Query" }

        public var message: String {
            switch self {
            case .unsupportedQuery(let query):
                "The query (\(query)) compiles to XPath, which cannot search shadow content. Use a query that compiles to a CSS selector, such as one on tags, ids, classes, or attributes, or find the host first and search its shadow root."
            }
        }

        public static func == (lhs: ShadowContentSearchError, rhs: ShadowContentSearchError) -> Bool {
            switch (lhs, rhs) {
            case (.unsupportedQuery(let lhs), .unsupportedQuery(let rhs)): lhs == rhs
            }
        }
    }

}


extension Element {

    /// Finds the first descendant of the element, searching the content of open shadow roots too, including the element's own.
    ///
    /// The element itself is not matched. See ``Session/Window/findElement(where:includingShadowContent:fileID:line:function:)`` for the order and limits of the search.
    ///
    /// - Throws: ``WebDriverError`` with ``WebDriverError/ErrorCode/no_such_element`` when nothing matches.
    public func findElement(where predicate: @Sendable (Session.Window.Element.LocatorProxy) -> any LocatorQuery, includingShadowContent: Bool, fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function) async throws -> Session.Window.Element {
        try await self.findElement(where: { predicate($0).makeQuery() }, includingShadowContent: includingShadowContent, fileID: fileID, line: line, function: function)
    }

    /// Finds the first descendant of the element, searching the content of open shadow roots too, including the element's own.
    ///
    /// See ``findElement(where:includingShadowContent:fileID:line:function:)``.
    public func findElement(where predicate: @Sendable (Session.Window.Element.LocatorProxy) -> Session.Window.Element.Query, includingShadowContent: Bool, fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function) async throws -> Session.Window.Element {
        guard includingShadowContent else {
            return try await self.findElement(where: predicate, fileID: fileID, line: line, function: function)
        }
        let query = predicate(Element.LocatorProxy())
        guard let element = try await ShadowContentSearch.first(matching: query, in: self.window, root: self, fileID: fileID, line: line, function: function) else {
            throw ShadowContentSearch.noSuchElement(query, window: self.window, context: SwiftContext(fileID: fileID, line: line, function: function))
        }
        return element
    }

    /// Finds the descendants of the element, searching the content of open shadow roots too, including the element's own.
    ///
    /// See ``findElement(where:includingShadowContent:fileID:line:function:)``.
    public func findElements(where predicate: @Sendable (Session.Window.Element.LocatorProxy) -> any LocatorQuery, includingShadowContent: Bool, fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function) async throws -> [Session.Window.Element] {
        try await self.findElements(where: { predicate($0).makeQuery() }, includingShadowContent: includingShadowContent, fileID: fileID, line: line, function: function)
    }

    /// Finds the descendants of the element, searching the content of open shadow roots too, including the element's own.
    ///
    /// See ``findElement(where:includingShadowContent:fileID:line:function:)``.
    public func findElements(where predicate: @Sendable (Session.Window.Element.LocatorProxy) -> Session.Window.Element.Query, includingShadowContent: Bool, fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function) async throws -> [Session.Window.Element] {
        guard includingShadowContent else {
            return try await self.findElements(where: predicate, fileID: fileID, line: line, function: function)
        }
        return try await ShadowContentSearch.all(matching: predicate(Element.LocatorProxy()), in: self.window, root: self, fileID: fileID, line: line, function: function)
    }

}


/// The search behind the `includingShadowContent` finders.
enum ShadowContentSearch {

    static func first(matching query: Element.Query, in window: Session.Window, root: Element?, fileID: StaticString, line: Int, function: StaticString) async throws -> Element? {
        try await window.execute(Self.script, args: Self.arguments(for: query, root: root, all: false), as: Element?.self, fileID: fileID, line: line, function: function)
    }

    static func all(matching query: Element.Query, in window: Session.Window, root: Element?, fileID: StaticString, line: Int, function: StaticString) async throws -> [Element] {
        try await window.execute(Self.script, args: Self.arguments(for: query, root: root, all: true), as: [Element].self, fileID: fileID, line: line, function: function)
    }

    static func noSuchElement(_ query: Element.Query, window: Session.Window, context: SwiftContext) -> WebDriverError {
        WebDriverError(code: .no_such_element, statusCode: 404, message: "Unable to locate element in the page or its shadow content: \(query)", context: context, origin: .window(window), invoker: "findElement(where:includingShadowContent:fileID:line:function:)")
    }

    /// The arguments of ``script``: the root element or `null`, the match mode, the value, and whether to find all matches.
    ///
    /// - Throws: ``Session/Window/ShadowContentSearchError/unsupportedQuery(_:)`` for XPath queries.
    private static func arguments(for query: Element.Query, root: Element?, all: Bool) throws -> [Any] {
        let mode = switch query.locator {
        case .css, .tagName: "css"
        case .linkText: "link"
        case .partialLinkText: "partialLink"
        case .xpath: throw Session.Window.ShadowContentSearchError.unsupportedQuery(query)
        }
        let root: Any = root.map { ["element-6066-11e4-a52e-4f735466cecf": $0.id] } ?? NSNull()
        return [root, mode, query.value, all]
    }

    /// Walks the document, or the root element, in page order, entering each open shadow root right after its host.
    private static let script = #"""
    const [root, mode, value, all] = arguments;
    const normalize = text => text.replace(/\s+/g, " ").trim();
    const matches = element => {
        switch (mode) {
        case "css":
            return element.matches(value);
        case "link":
            return element.localName === "a" && normalize(element.innerText ?? element.textContent) === value;
        case "partialLink":
            return element.localName === "a" && normalize(element.innerText ?? element.textContent).includes(value);
        }
        return false;
    };
    const results = [];
    // Returns `true` once the first match is found, when not finding all.
    const visit = tree => {
        for (const element of tree.querySelectorAll("*")) {
            if (matches(element)) {
                results.push(element);
                if (!all) return true;
            }
            if (element.shadowRoot && visit(element.shadowRoot)) return true;
        }
        return false;
    };
    if (root) {
        if (!(root.shadowRoot && visit(root.shadowRoot))) visit(root);
    } else {
        visit(document);
    }
    return all ? results : (results[0] ?? null);
    """#

}
