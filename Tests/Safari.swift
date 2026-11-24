//
//  Safari.swift
//  WebDriver
//
//  Created by Claude on 11/24/26.
//

import Foundation
import Testing
@testable
import WebDriver


@Suite(.serialized)
struct SafariTests {

    @Test
    func browserNameIsSafari() throws {
        let driver = try WebDriver.Safari()
        #expect(driver.capabilities["browserName"] as? String == "safari")
    }

    @Test
    func safariCapabilities() throws {
        let driver = try WebDriver.Safari()
            .automaticInspection()
            .automaticProfiling(false)
            .pageLoadStrategy(.eager)
        #expect(driver.capabilities["safari:automaticInspection"] as? Bool == true)
        #expect(driver.capabilities["safari:automaticProfiling"] as? Bool == false)
        #expect(driver.capabilities["pageLoadStrategy"] as? String == "eager")
        #expect(driver.capabilities["browserName"] as? String == "safari")
    }

    @Test
    func timeoutsApplyToSafari() throws {
        let driver = try WebDriver.Safari().timeouts(Session.Timeout(implicit: .seconds(1)))
        let timeouts = try #require(driver.capabilities["timeouts"] as? [String : Any])
        #expect(timeouts["implicit"] as? Int == 1_000)
    }

    @Test
    func pathOverride() {
        DriverEnvironment.$override.withValue(["WEBDRIVER_SAFARI_PATH": "/usr/bin/true"]) {
            #expect(WebDriver.Safari.safariDriverPath == "/usr/bin/true")
        }
    }

    @Test(.timeLimit(.minutes(1)))
    func failingDriverFailsFast() async throws {
        try await DriverEnvironment.$override.withValue(["WEBDRIVER_SAFARI_PATH": "/usr/bin/false"]) {
            let start = ContinuousClock.now
            await #expect {
                _ = try await WebDriver.Safari().startSession()
            } throws: { error in
                guard case WebDriver.InitializationError.exceededMaxRetries(3, let output) = error else { return false }
                return output.contains("safaridriver exited with status 1")
            }
            #expect(ContinuousClock.now - start < .seconds(3))
        }
    }

}
