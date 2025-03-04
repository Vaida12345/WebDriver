//
//  WebDriverLauncher.swift
//  WebDriver
//
//  Created by Vaida on 3/4/25.
//

import Foundation


public protocol WebDriverLauncher<Driver> {
    
    var driver: Driver { get }
    
    var port: UInt16 { get }
    
    var url: URL { get }
    
    func stop()
    
    associatedtype Driver: WebDriverProtocol
    
}


extension WebDriverLauncher {
    
    public var baseURL: URL {
        URL(string: "http://\(self.url.absoluteString):\(self.port)")!
    }
}
