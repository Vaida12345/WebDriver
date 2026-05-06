//
//  GeckoLauncher.swift
//  WebDriver
//
//  Created by Vaida on 3/4/25.
//

import Foundation
import OSLog
import FinderItem
import Essentials
import ChildProcess
import System


final class GeckoLauncher: WebDriverLauncher {
    
    private let process: ChildProcess
    
    public let driver: WebDriver.Firefox
    
    public let port: UInt16
    
    public let url: URL
    
    
    public func stop() {
        self.process.terminate()
        
        if driver.flags.contains(.deleteProfileAfterUse),
           let options = driver.capabilities["moz:firefoxOptions"] as? [String : Any],
           let args = options["args"] as? [String],
           let firstIndex = args.firstIndex(of: "-profile"),
           args.count > firstIndex + 1 {
            let profile = args[firstIndex + 1]
            do {
                try FinderItem(at: profile).removeIfExists()
            } catch {
                let logger = Logger(subsystem: "WebDriver", category: "GeckoLauncher")
                logger.fault("Failed to delete profile: \(error)")
            }
        }
    }
    
    
    /// Creates and launches a `geckodriver` process for the provided Firefox driver.
    ///
    /// - Parameters:
    ///   - driver: The configured Firefox driver.
    ///   - maxRetryCount: Number of random-port retries before failing.
    init(driver: Driver, maxRetryCount: Int = 3) async throws {
        self.driver = driver
        
        guard let geckoDriverPath = WebDriver.Firefox.geckoDriverPath else {
            throw WebDriver.InitializationError.driverNotAvailable
        }
        
        let port = generateRandomPort()
        let process = try ChildProcess.makeProcess(
            .path(FilePath(geckoDriverPath)),
            arguments: ["--host", "127.0.0.1", "-p", port.description]
        )
        
        try await Self.waitUntilReady(host: "127.0.0.1", port: port)
        
        let logger = Logger(subsystem: "GeckoLauncher", category: #function)
        logger.info("geckodriver launched at 127.0.0.1:\(port)")
        
        self.url = URL(string: "127.0.0.1")!
        self.port = port
        self.process = process
    }
    
    /// Waits until `geckodriver` reports ready on `/status`.
    ///
    /// - Parameters:
    ///   - host: The loopback host used by `geckodriver`.
    ///   - port: The listening port used by `geckodriver`.
    ///   - timeout: Maximum amount of time to wait for readiness.
    private static func waitUntilReady(host: String, port: UInt16, timeout: Duration = .seconds(10)) async throws {
        guard let statusURL = URL(string: "http://\(host):\(port)/status") else {
            throw WebDriver.InitializationError.driverStartFailed
        }
        
        let deadline = ContinuousClock.now.advanced(by: timeout)
        let session = URLSession(configuration: .ephemeral)
        defer { session.invalidateAndCancel() }
        
        while ContinuousClock.now < deadline {
            do {
                let (_, response) = try await session.data(from: statusURL)
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw WebDriver.InitializationError.driverStartFailed
                }
                guard (200..<500).contains(httpResponse.statusCode) else {
                    try await Task.sleep(for: .milliseconds(100))
                    continue
                }
                return
            } catch {
                try await Task.sleep(for: .milliseconds(100))
            }
        }
        
        throw WebDriver.InitializationError.driverStartFailed
    }
    
    
    deinit {
        self.stop()
    }
    
}
