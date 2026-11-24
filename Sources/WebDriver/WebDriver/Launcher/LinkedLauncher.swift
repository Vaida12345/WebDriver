//
//  LinkedLauncher.swift
//  WebDriver
//
//  Created by Vaida on 3/6/25.
//

import Foundation


/// An existing launcher.
final class LinkedLauncher<Driver: WebDriverProtocol>: WebDriverLauncher {

    public let driver: Driver

    public let host: String

    public let port: UInt16

    public func attach(sessionID: String) {

    }

    /// Does nothing, as the server is not owned by this launcher.
    public func stop() async {

    }


    init(driver: Driver, host: String, port: UInt16) {
        self.driver = driver
        self.host = host
        self.port = port
    }


}
