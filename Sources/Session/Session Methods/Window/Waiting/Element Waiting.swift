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
    public func wait(
        until condition: ElementWaitCondition,
        timeout: Duration,
        where predicate: @Sendable (Element.LocatorProxy) -> any LocatorQuery,
        fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function
    ) async throws -> Element {
        try await self.wait(until: condition, timeout: timeout, where: { predicate($0).makeQuery() }, fileID: fileID, line: line, function: function)
    }
    
    
    /// - throws: On time out, throws ``WaitingTimeout``.
    public func wait(
        until condition: ElementWaitCondition,
        timeout: Duration,
        where predicate: @Sendable (Element.LocatorProxy) -> Element.Query,
        fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function
    ) async throws -> Element {
        let startDate = Date()
        let waitPeriod: Duration = .seconds(0.2)
        
        let proxy = Element.LocatorProxy()
        let query = predicate(proxy)
        
        while Date() < startDate.addingTimeInterval(timeout.seconds) {
            do {
                let element = try await self.findElement(where: predicate, fileID: fileID, line: line, function: function)
                switch condition {
                case .elementPresence:
                    return element
                case .elementEnabled:
                    guard try await element.isEnabled else {
                        try await Task.sleep(for: waitPeriod)
                        continue
                    }
                    return element
                }
            } catch let error as WebDriverError where error.code == .no_such_element {
                try await Task.sleep(for: waitPeriod)
                continue
            } catch {
                throw error
            }
        }
        
        let source = try? await self.pageSource
        
        throw WaitingTimeout(duration: timeout, query: query, details: source)
    }
    
    
    public struct WaitingTimeout: GenericError, @unchecked Sendable {
        
        let duration: Duration
        
        let query: Element.Query?
        
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
