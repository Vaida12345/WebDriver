//
//  Chrome.swift
//  WebDriver
//
//  Created by Claude on 11/25/26.
//

import Foundation
import Testing
import FinderItem
@testable
import WebDriver


@Suite(.serialized)
struct ChromeTests {
    
    private static func options(of driver: WebDriver.Chrome) -> [String : Any] {
        driver.capabilities["goog:chromeOptions"] as? [String : Any] ?? [:]
    }
    
    @Test
    func browserNameIsChrome() throws {
        let driver = try WebDriver.Chrome()
        #expect(driver.capabilities["browserName"] as? String == "chrome")
        #expect(try driver.chromeArgs().isEmpty)
    }
    
    @Test
    func chromeOptions() throws {
        let driver = try WebDriver.Chrome()
            .headless()
            .windowSize(width: 1280, height: 800)
            .arguments(["--lang=en-US"])
            .binary(location: FinderItem(at: "/Applications/Brave Browser.app"))
            .pageLoadStrategy(.eager)
        
        #expect(try driver.chromeArgs() == ["--headless=new", "--window-size=1280,800", "--lang=en-US"])
        #expect(Self.options(of: driver)["binary"] as? String == "/Applications/Brave Browser.app/Contents/MacOS/Brave Browser")
        #expect(driver.capabilities["pageLoadStrategy"] as? String == "eager")
    }
    
    @Test
    func switchesAreReplaced() throws {
        let driver = try WebDriver.Chrome()
            .windowSize(width: 100, height: 100)
            .windowSize(width: 200, height: 300)
            .headless()
            .headless(false)
        #expect(try driver.chromeArgs() == ["--window-size=200,300"])
        #expect(driver.chromeArg(prefix: "--window-size") == "200,300")
    }
    
    @Test
    func copiedProfile() throws {
        let driver = try WebDriver.Chrome().profile(location: FinderItem(at: "/tmp/chrome data"), directory: "Profile 1")
        #expect(driver.flags.contains(.copyProfileOnLaunch))
        #expect(driver.chromeArg(prefix: "--user-data-dir") == "/tmp/chrome data")
        #expect(driver.chromeArg(prefix: "--profile-directory") == "Profile 1")
        
        let inPlace = try driver.profile(noCopying: FinderItem(at: "/tmp/other"))
        #expect(!inPlace.flags.contains(.copyProfileOnLaunch))
        #expect(inPlace.chromeArg(prefix: "--user-data-dir") == "/tmp/other")
        #expect(inPlace.chromeArg(prefix: "--profile-directory") == nil)
    }
    
    @Test
    func pathOverride() {
        DriverEnvironment.$override.withValue(["WEBDRIVER_CHROME_PATH": "/usr/bin/true"]) {
            #expect(WebDriver.Chrome.chromeDriverPath == "/usr/bin/true")
        }
    }
    
    @Test(.timeLimit(.minutes(1)))
    func failingDriverFailsFast() async throws {
        try await DriverEnvironment.$override.withValue(["WEBDRIVER_CHROME_PATH": "/usr/bin/false"]) {
            let start = ContinuousClock.now
            await #expect {
                _ = try await WebDriver.Chrome().startSession()
            } throws: { error in
                guard case WebDriver.InitializationError.exceededMaxRetries(3, let output) = error else { return false }
                return output.contains("chromedriver exited with status 1")
            }
            #expect(ContinuousClock.now - start < .seconds(3))
        }
    }
    
}
