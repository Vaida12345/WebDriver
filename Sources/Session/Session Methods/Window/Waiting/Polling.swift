//
//  Polling.swift
//  WebDriver
//
//  Created by Claude on 11/25/26.
//


/// Calls `attempt` until it returns `true`, or until `timeout` passes.
///
/// `attempt` is called at least once, even for a zero timeout. Between calls, it sleeps for `interval`, or for what is left of `timeout` if that is shorter.
///
/// - Returns: Whether `attempt` returned `true` before the timeout.
func poll(timeout: Duration, interval: Duration, isolation: isolated (any Actor)? = #isolation, _ attempt: () async throws -> Bool) async throws -> Bool {
    let clock = ContinuousClock()
    let deadline = clock.now.advanced(by: timeout)

    repeat {
        if try await attempt() { return true }

        let remaining = clock.now.duration(to: deadline)
        guard remaining > .zero else { break }
        try await clock.sleep(for: min(remaining, interval))
    } while clock.now < deadline

    return false
}
