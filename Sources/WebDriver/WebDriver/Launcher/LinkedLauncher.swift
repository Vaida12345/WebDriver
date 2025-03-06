//
//  LinkedLauncher.swift
//  WebDriver
//
//  Created by Vaida on 3/6/25.
//

import Foundation


/// An existing launcher.
public final class LinkedLauncher<Driver: WebDriverProtocol>: WebDriverLauncher {
    
    public var driver: Driver
    
    public var port: UInt16
    
    public var url: URL
    
    public func stop() {
        
    }
    
    
    init(driver: Driver,  url: URL, port: UInt16) {
        self.driver = driver
        self.port = port
        self.url = url
    }
    
    
}
