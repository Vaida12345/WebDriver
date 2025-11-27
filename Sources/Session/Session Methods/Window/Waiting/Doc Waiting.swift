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
        
        while clock.now < deadline {
            switch condition {
            case .documentReady:
                guard try await self.readyState == .complete else {
                    try await sleepBeforeRetry()
                    continue
                }
                return
            }
        }
        
        throw WaitingTimeout(duration: timeout, query: nil)
    }
    
}
