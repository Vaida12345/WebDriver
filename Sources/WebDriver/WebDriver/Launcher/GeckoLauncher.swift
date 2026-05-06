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
    init(driver: Driver, maxRetryCount: Int = 10) async throws {
        self.driver = driver
        
        var counter: Int = 0
        var port = UInt16.random(in: 49152...65535)
        
        guard let geckoDriverPath = WebDriver.Firefox.geckoDriverPath else {
            throw WebDriver.InitializationError.driverNotAvailable
        }
        
        var process = try ChildProcess.makeProcess(.path(FilePath(geckoDriverPath)), arguments: ["-p", port.description])
        

        while counter < maxRetryCount {
            var stdout = process.stdout.bytes.lines.makeAsyncIterator()
            
            let line = try await stdout.next()
            guard let (_, url, port) = line?.wholeMatch(of: /\d+\s+geckodriver\s+INFO\s+Listening on (\d+\.\d+\.\d+\.\d+)\:(\d+)/)?.output else {
                process.terminate()
                process = try ChildProcess.makeProcess(.path(FilePath(geckoDriverPath)), arguments: ["-p", port.description])
                port = UInt16.random(in: 49152...65535)
                counter += 1
                
                continue
            }
            
            let logger = Logger(subsystem: "GeckoLauncher", category: #function)
            logger.info("geckodriver launched at \(url):\(port)")
            
            self.url = URL(string: "\(url)")!
            self.port = UInt16(port)!
            self.process = process
            return
        }
        
        throw WebDriver.InitializationError.exceededMaxRetries(maxRetryCount)
    }
    
    
    deinit {
        self.stop()
    }
    
}
