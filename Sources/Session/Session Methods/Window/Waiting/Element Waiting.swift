//
//  Waiting.swift
//  WebDriver
//
//  Created by Vaida on 5/2/25.
//

import Essentials
import Foundation


extension Session.Window {
    
    public enum ElementWaitCondition {
        case elementPresence
        case elementEnabled
    }
    
    
    /// - throws: On time out, throws ``WaitingTimeout``.
    ///
    /// - Note: This method cannot be used to find elements inside a shadow content.
    public func wait(
        until condition: ElementWaitCondition,
        timeout: Duration,
        where predicate: @Sendable (Element.LocatorProxy) -> any LocatorQuery,
        fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function
    ) async throws -> Element {
        try await self.wait(until: condition, timeout: timeout, where: { predicate($0).makeQuery() }, fileID: fileID, line: line, function: function)
    }
    
    
    /// - throws: On time out, throws ``WaitingTimeout``.
    ///
    /// - Note: This method cannot be used to find elements inside a shadow content.
    public func wait(
        until condition: ElementWaitCondition,
        timeout: Duration,
        where predicate: @Sendable (Element.LocatorProxy) -> Element.Query,
        fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function
    ) async throws -> Element {
        let waitPeriod: Duration = .seconds(0.2)
        let clock = ContinuousClock()
        let deadline = clock.now.advanced(by: timeout)
        
        @inline(__always)
        func sleepBeforeRetry() async throws {
            let remaining = clock.now.duration(to: deadline)
            guard remaining > .zero else { return }
            let sleepDuration = remaining < waitPeriod ? remaining : waitPeriod
            try await clock.sleep(for: sleepDuration)
        }
        
        let proxy = Element.LocatorProxy()
        let query = predicate(proxy)
        
        // `repeat`, so that the element is looked for at least once, even for a zero timeout.
        repeat {
            do {
                let element = try await self.findElement(where: predicate, fileID: fileID, line: line, function: function)
                switch condition {
                case .elementPresence:
                    return element
                case .elementEnabled:
                    guard try await element.isEnabled else {
                        try await sleepBeforeRetry()
                        continue
                    }
                    return element
                }
            } catch let error as WebDriverError where error.code == .no_such_element || error.code == .stale_element_reference {
                // A stale element was replaced between being found and being checked, so it is looked up again.
                try await sleepBeforeRetry()
                continue
            } catch {
                throw error
            }
        } while clock.now < deadline
        
        let snapshot = await self.timeoutDetails

        throw WaitingTimeout(duration: timeout, query: query, details: snapshot)
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
