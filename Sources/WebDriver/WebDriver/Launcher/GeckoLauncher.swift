//
//  GeckoLauncher.swift
//  WebDriver
//
//  Created by Vaida on 3/4/25.
//

import Foundation


final class GeckoLauncher: WebDriverLauncher {
    
    internal let manager: ShellManager
    
    public let driver: WebDriver.Firefox
    
    public let port: UInt16
    
    public let url: URL
    
    
    public func stop() {
        self.manager.terminate()
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
