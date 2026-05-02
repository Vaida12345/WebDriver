//
//  GeckoLauncher.swift
//  WebDriver
//
//  Created by Vaida on 3/4/25.
//

import Foundation
import OSLog
import FinderItem


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
           args.count >= firstIndex + 1 {
            let profile = args[firstIndex + 1]
            do {
                try FinderItem(at: profile).removeIfExists()
            } catch {
                let logger = Logger(subsystem: "WebDriver", category: "GeckoLauncher")
                logger.fault("Failed to delete profile: \(error)")
            }
        }
    }
    
    
    init(driver: Driver) async throws {
        self.driver = driver
        
        var manager = ShellManager()
        var port = UInt16.random(in: 49152...65535)
        
        while true {
            try manager.run(arguments: "/opt/homebrew/bin/geckodriver -p \(port)")
            var stdout = manager.lines().makeAsyncIterator()
            
            let line = try await stdout.next()
            guard let (_, url, port) = line?.wholeMatch(of: /\d+\s+geckodriver\s+INFO\s+Listening on (\d+\.\d+\.\d+\.\d+)\:(\d+)/)?.output else {
                manager.terminate()
                manager = ShellManager()
                port = UInt16.random(in: 49152...65535)
                
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
    }
    
    
    deinit {
        self.stop()
    }
    
}
