//
//  Doc Waiting.swift
//  WebDriver
//
//  Created by Vaida on 5/3/25.
//

import Essentials
import Foundation


extension Session.Window {
    
    public enum DocWaitCondition {
        /// Wait until document `ReadyState` is `complete`.
        case documentReady
    }
    
    /// - throws: On time out, throws ``WaitingTimeout``.
    public func wait(
        until condition: DocWaitCondition,
        timeout: Duration
    ) async throws {
        let startDate = Date()
        let waitPeriod: Duration = .seconds(0.2)
        
        while Date() < startDate.addingTimeInterval(timeout.seconds) {
            switch condition {
            case .documentReady:
                guard try await self.readyState == .complete else {
                    try await Task.sleep(for: waitPeriod)
                    continue
                }
                return
            }
        }
        
        throw WaitingTimeout(duration: timeout, query: nil)
    }
    
}
