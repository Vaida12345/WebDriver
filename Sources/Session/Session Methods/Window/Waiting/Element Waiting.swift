//
//  Waiting.swift
//  WebDriver
//
//  Created by Vaida on 5/2/25.
//

import Essentials
import Foundation


extension Session.Window {
    
    public enum ElementWaitCondition: Sendable {
        /// The element is in the document.
        case elementPresence
        
        /// The element is in the document and enabled.
        case elementEnabled
        
        /// The element is in the document and visible, as reported by ``Element/isVisible``.
        case elementVisible
    }
    
    
    /// Waits until an element matching `predicate` meets `condition`, and returns it.
    ///
    /// - Parameters:
    ///   - condition: The condition to wait for.
    ///   - timeout: How long to wait. The element is looked for at least once, even for a zero timeout.
    ///   - pollingInterval: How long to wait between checks.
    ///   - predicate: The element to wait for.
    ///
    /// - throws: On time out, throws ``WaitingTimeout``.
    ///
    /// - Note: Elements inside a shadow root are not found. Find them through ``Session/Window/Element/shadowRoot`` instead.
    public func wait(
        until condition: ElementWaitCondition,
        timeout: Duration,
        pollingInterval: Duration = .milliseconds(200),
        where predicate: @Sendable (Element.LocatorProxy) -> any LocatorQuery,
        fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function
    ) async throws -> Element {
        try await self.wait(until: condition, timeout: timeout, pollingInterval: pollingInterval, where: { predicate($0).makeQuery() }, fileID: fileID, line: line, function: function)
    }
    
    
    /// Waits until an element matching `predicate` meets `condition`, and returns it.
    ///
    /// - Parameters:
    ///   - condition: The condition to wait for.
    ///   - timeout: How long to wait. The element is looked for at least once, even for a zero timeout.
    ///   - pollingInterval: How long to wait between checks.
    ///   - predicate: The element to wait for.
    ///
    /// - throws: On time out, throws ``WaitingTimeout``.
    ///
    /// - Note: Elements inside a shadow root are not found. Find them through ``Session/Window/Element/shadowRoot`` instead.
    public func wait(
        until condition: ElementWaitCondition,
        timeout: Duration,
        pollingInterval: Duration = .milliseconds(200),
        where predicate: @Sendable (Element.LocatorProxy) -> Element.Query,
        fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function
    ) async throws -> Element {
        let query = predicate(Element.LocatorProxy())
        var found: Element?
        
        let succeeded = try await poll(timeout: timeout, interval: pollingInterval) {
            do {
                let element = try await self.findElement(where: predicate, fileID: fileID, line: line, function: function)
                let meetsCondition = switch condition {
                case .elementPresence: true
                case .elementEnabled: try await element.isEnabled
                case .elementVisible: try await element.isVisible
                }
                found = meetsCondition ? element : nil
                return meetsCondition
            } catch let error as WebDriverError where error.code == .no_such_element || error.code == .stale_element_reference {
                // A stale element was replaced between being found and being checked, so it is looked up again.
                return false
            }
        }
        
        if succeeded, let found {
            return found
        }
        throw WaitingTimeout(duration: timeout, query: query, details: await self.timeoutDetails)
    }
    
    
    /// Waits until no element matches `predicate`, for example, until a spinner is gone.
    ///
    /// - Parameters:
    ///   - timeout: How long to wait. The elements are looked for at least once, even for a zero timeout.
    ///   - pollingInterval: How long to wait between checks.
    ///   - predicate: The elements to wait for to disappear.
    ///
    /// - throws: On time out, throws ``WaitingTimeout``.
    public func waitUntilAbsent(
        timeout: Duration,
        pollingInterval: Duration = .milliseconds(200),
        where predicate: @Sendable (Element.LocatorProxy) -> any LocatorQuery,
        fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function
    ) async throws {
        let query = predicate(Element.LocatorProxy()).makeQuery()
        
        let succeeded = try await poll(timeout: timeout, interval: pollingInterval) {
            try await self.findElements(where: predicate, fileID: fileID, line: line, function: function).isEmpty
        }
        
        guard succeeded else {
            throw WaitingTimeout(duration: timeout, query: query, details: await self.timeoutDetails)
        }
    }
    
    
    /// Waits until `condition` returns `true`.
    ///
    /// ```swift
    /// try await window.wait(timeout: .seconds(5)) {
    ///     try await window.findElements(where: { $0.tag == "li" }).count >= 10
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - timeout: How long to wait. `condition` is called at least once, even for a zero timeout.
    ///   - pollingInterval: How long to wait between calls.
    ///   - condition: The condition to wait for. Errors it throws are rethrown, ending the wait.
    ///
    /// - throws: On time out, throws ``WaitingTimeout``.
    public func wait(
        timeout: Duration,
        pollingInterval: Duration = .milliseconds(200),
        isolation: isolated (any Actor)? = #isolation,
        until condition: () async throws -> Bool
    ) async throws {
        // Runs in the caller's isolation, so that `condition` can use the caller's state.
        guard try await poll(timeout: timeout, interval: pollingInterval, isolation: isolation, condition) else {
            throw WaitingTimeout(duration: timeout, query: nil, details: await self.timeoutDetails)
        }
    }
    
    
    public struct WaitingTimeout: GenericError, @unchecked Sendable {
        
        let duration: Duration
        
        let query: Element.Query?
        
        /// A trimmed snapshot of the DOM at the time of the timeout.
        ///
        /// Contents of `script`, `style`, `noscript`, `svg`, and `template` are replaced with a size marker, comments are removed, and long attribute values are shortened. Falls back to the full page source if the snapshot could not be taken.
        public var details: String?
        
        public var message: String {
            if let query {
                "Waiting for an element (\(query)) timed out (\(duration.description))"
            } else {
                "Waiting timed out (\(duration.description))"
            }
        }
    }
    
}
