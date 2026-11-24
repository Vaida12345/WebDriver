//
//  Doc Waiting.swift
//  WebDriver
//
//  Created by Vaida on 5/3/25.
//

import Essentials
import Foundation


extension Session.Window {
    
    public enum DocWaitCondition: Sendable {
        /// Wait until document `ReadyState` is `complete`.
        case documentReady
        
        /// Wait until the URL of the top-level document contains the string.
        case urlContains(String)
        
        /// Wait until the title of the document contains the string.
        case titleContains(String)
        
        /// Wait until a user prompt, such as an alert, is open. See ``Session/Window/alert``.
        case alertPresent
    }
    
    /// Waits until the document meets `condition`.
    ///
    /// - Parameters:
    ///   - condition: The condition to wait for.
    ///   - timeout: How long to wait. The condition is checked at least once, even for a zero timeout.
    ///   - pollingInterval: How long to wait between checks.
    ///
    /// - throws: On time out, throws ``WaitingTimeout``.
    public func wait(
        until condition: DocWaitCondition,
        timeout: Duration,
        pollingInterval: Duration = .milliseconds(200)
    ) async throws {
        let succeeded = try await poll(timeout: timeout, interval: pollingInterval) {
            switch condition {
            case .documentReady:
                return try await self.readyState == .complete
            case .urlContains(let string):
                try await self.becomeFirstResponder(context: .unavailable)
                return try await self.session.url.absoluteString.contains(string)
            case .titleContains(let string):
                try await self.becomeFirstResponder(context: .unavailable)
                return try await self.session.title.contains(string)
            case .alertPresent:
                do {
                    _ = try await self.alert.text
                    return true
                } catch let error as WebDriverError where error.code == .no_such_alert {
                    return false
                }
            }
        }
        
        guard succeeded else {
            throw WaitingTimeout(duration: timeout, query: nil, details: await self.timeoutDetails)
        }
    }
    
}
