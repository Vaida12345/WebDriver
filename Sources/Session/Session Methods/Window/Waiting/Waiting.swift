//
//  Waiting.swift
//  WebDriver
//
//  Created by Vaida on 5/2/25.
//

import Essentials
import Foundation


extension Session.Window {
    
    public enum WaitCondition {
        case elementPresence
        case elementEnabled
    }
    
    
    /// - throws: On time out, throws ``WaitingTimeout``.
    public func wait(
        until condition: WaitCondition,
        timeout: Duration,
        where predicate: @Sendable (Element.LocatorProxy) -> any LocatorQuery
    ) async throws -> Element {
        try await self.wait(until: condition, timeout: timeout, where: { predicate($0).makeQuery() })
    }
    
    
    /// - throws: On time out, throws ``WaitingTimeout``.
    public func wait(
        until condition: WaitCondition,
        timeout: Duration,
        where predicate: @Sendable (Element.LocatorProxy) -> Element.Query
    ) async throws -> Element {
        let startDate = Date()
        let waitPeriod: Duration = .seconds(0.2)
        
        while Date() < startDate.addingTimeInterval(timeout.seconds) {
            do {
                let element = try await self.findElement(where: predicate)
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
            } catch let error as ServerError where error.code == .no_such_element {
                try await Task.sleep(for: waitPeriod)
                continue
            } catch {
                throw error
            }
        }
        
        throw WaitingTimeout()
    }
    
    
    public struct WaitingTimeout: GenericError {
        
        public var message: String {
            "Waiting for an element timed out"
        }
    }
    
}
