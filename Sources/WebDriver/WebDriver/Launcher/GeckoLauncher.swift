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


final class GeckoLauncher: WebDriverLauncher {
    
    private let manager: ShellManager
    
    public let driver: WebDriver.Firefox
    
    public let port: UInt16
    
    public let url: URL
    
    
    public func stop() {
        self.manager.terminate()
        
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
    init(driver: Driver, maxRetryCount: Int = 10) async throws {
        self.driver = driver
        
        var manager = ShellManager()
        var port = UInt16.random(in: 49152...65535)
        
        var counter: Int = 0
        
        guard let geckoDriverPath = WebDriver.Firefox.geckoDriverPath else {
            throw WebDriver.InitializationError.driverNotAvailable
        }

        while counter < maxRetryCount {
            try manager.run(arguments: "\(geckoDriverPath) -p \(port)")
            var stdout = manager.lines().makeAsyncIterator()
            
            let line = try await stdout.next()
            guard let (_, url, port) = line?.wholeMatch(of: /\d+\s+geckodriver\s+INFO\s+Listening on (\d+\.\d+\.\d+\.\d+)\:(\d+)/)?.output else {
                manager.terminate()
                manager = ShellManager()
                port = UInt16.random(in: 49152...65535)
                counter += 1
                
                continue
            }
            
            let logger = Logger(subsystem: "GeckoLauncher", category: #function)
            logger.info("geckodriver launched at \(url):\(port)")
            
            self.url = URL(string: "\(url)")!
            self.port = UInt16(port)!
            self.manager = manager
            self.manager.terminationHandler = { _ in
                logger.info("geockodriver terminated")
            }
            return
        }
        
        throw WebDriver.InitializationError.exceededMaxRetries(maxRetryCount)
    }
    
    
    deinit {
        self.stop()
    }
    
}
