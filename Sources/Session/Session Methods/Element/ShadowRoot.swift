//
//  ShadowRoot.swift
//  WebDriver
//
//  Created by Claude on 11/25/26.
//

import Essentials
import JSONParser


extension Session.Window {

    /// The shadow root attached to an element, such as a web component.
    ///
    /// Elements inside a shadow root cannot be found from the document or from the host element. Find them through the shadow root instead:
    ///
    /// ```swift
    /// let host = try await window.findElement(where: { $0.tag == "my-component" })
    /// let button = try await host.shadowRoot.findElement(where: { $0.tag == "button" })
    /// ```
    ///
    /// To search the content of every open shadow root at once, without finding the hosts first, use ``Session/Window/findElement(where:includingShadowContent:fileID:line:function:)``.
    ///
    /// - Important: Browsers support CSS selectors, tag names, and link text inside shadow roots, but usually not XPath. Queries that compile to XPath, such as those matching text, may fail with ``WebDriverError/ErrorCode/invalid_argument`` or ``WebDriverError/ErrorCode/invalid_selector``.
    ///
    /// ## See Also
    /// - [W3C WebDriver Specification – Shadow Roots](https://www.w3.org/TR/webdriver2/#shadow-root)
    public struct ShadowRoot: Sendable, Equatable {

        /// The shadow root id.
        let id: String

        /// The element the shadow root is attached to.
        public let host: Element


        /// Finds the first element inside the shadow root.
        public func findElement(where predicate: @Sendable (Element.LocatorProxy) -> any LocatorQuery, fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function) async throws -> Element {
            try await self.findElement(where: { predicate($0).makeQuery() }, fileID: fileID, line: line, function: function)
        }

        /// Finds the first element inside the shadow root.
        public func findElement(where predicate: @Sendable (Element.LocatorProxy) -> Element.Query, fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function) async throws -> Element {
            let context = SwiftContext(fileID: fileID, line: line, function: function)
            let parser = try await self.find("element", query: predicate(Element.LocatorProxy()), context: context)
            return try Element(parser: parser.decode(JSONParser.self, forKey: "value"), window: self.host.window, context: context)
        }

        /// Finds the elements inside the shadow root.
        public func findElements(where predicate: @Sendable (Element.LocatorProxy) -> any LocatorQuery, fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function) async throws -> [Element] {
            try await self.findElements(where: { predicate($0).makeQuery() }, fileID: fileID, line: line, function: function)
        }

        /// Finds the elements inside the shadow root.
        public func findElements(where predicate: @Sendable (Element.LocatorProxy) -> Element.Query, fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function) async throws -> [Element] {
            let context = SwiftContext(fileID: fileID, line: line, function: function)
            let parser = try await self.find("elements", query: predicate(Element.LocatorProxy()), context: context)
            return try parser.decode([JSONParser].self, forKey: "value").map { try Element(parser: $0, window: self.host.window, context: context) }
        }

        private func find(_ endpoint: String, query: Element.Query, context: SwiftContext) async throws -> JSONParser {
            try await self.host.window.becomeFirstResponder(context: context)

            // XPath is made relative, so that it is evaluated against the shadow root rather than the document.
            let query = query.relativeToContextNode()
            let (data, _) = try await self.host.window.session.data(
                .post,
                "/session/\(self.host.window.session.id)/shadow/\(self.id)/\(endpoint)",
                json: ["using": query.locator.rawValue, "value": query.value],
                context: context,
                origin: .element(self.host),
                invoker: "ShadowRoot.findElement(where:)"
            )
            return try JSONParser(data: data)
        }

    }

}


extension Element {

    /// The shadow root attached to the element.
    ///
    /// - Throws: ``WebDriverError`` with ``WebDriverError/ErrorCode/no_such_shadow_root`` when the element has none, or its shadow root is closed.
    public var shadowRoot: Session.Window.ShadowRoot {
        get async throws {
            let parser = try await self.parser(.get, "shadow", context: .unavailable, invoker: "Element.shadowRoot")
            let id = try parser.decode(JSONParser.self, forKey: "value").decode(String.self, forKey: "shadow-6066-11e4-a52e-4f735466cecf")
            return Session.Window.ShadowRoot(id: id, host: self)
        }
    }

}
