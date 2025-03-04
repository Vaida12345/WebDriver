//
//  GeckoLauncher.swift
//  WebDriver
//
//  Created by Vaida on 3/4/25.
//

import Foundation
import OSLog


public final class GeckoLauncher: WebDriverLauncher {
    
    public let manager: ShellManager
    
    public let driver: WebDriver.Firefox
    
    public let port: UInt16
    
    public let url: URL
    
    
    public func stop() {
        self.manager.terminate()
    }
    
    
    init(driver: Driver) async throws {
        self.driver = driver
        
        guard !ProcessInfo.processInfo.environment.keys.contains(where: { $0.contains("XCODE") }) else {
            let logger = Logger(subsystem: "WebDriver", category: "WebDriver Launcher")
            logger.critical("A webdriver cannot be launched correctly in Xcode environment. Please launch the executable directly. This program will exit.")
            exit(1)
        }
        
        var manager = ShellManager()
        var port = UInt16.random(in: 49152...65535)
        
        while true {
            try manager.run(arguments: "geckodriver -p \(port)")
            var stdout = manager.lines().makeAsyncIterator()
            
            let line = try await stdout.next()
            guard let (_, url, port) = line?.wholeMatch(of: /\d+\s+geckodriver\s+INFO\s+Listening on (\d+\.\d+\.\d+\.\d+)\:(\d+)/)?.output else {
                manager.terminate()
                manager = ShellManager()
                port = UInt16.random(in: 49152...65535)
                
                continue
            }
            
            self.url = URL(string: "\(url)")!
            self.port = UInt16(port)!
            self.manager = manager
            return
        }
    }
    
    
    deinit {
        self.stop()
    }
    
}
