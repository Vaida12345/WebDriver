//
//  Firefox.swift
//  WebDriver
//
//  Created by Vaida on 2/26/25.
//

import Foundation
import FinderItem


extension WebDriver {
    
    /// The Firefox WebDriver.
    public struct Firefox: WebDriverProtocol {
        
        public var capabilities: [String : Any]
        
        
        public func startSession() async throws -> Session {
            let launcher = try await GeckoLauncher(driver: self)
            return try await Session(launcher: launcher)
        }
        
        
        public init(capabilities: [String : Any]) {
            self.capabilities = capabilities
        }
        
        /// Initialize the WebDriver.
        public init() {
            self.init(capabilities: [:])
        }
        
    }
    
}


public extension WebDriver.Firefox {
    
    internal func appendingFirefoxCapability(key: String, value: String) -> WebDriver.Firefox {
        var capabilities = self.capabilities // copy
        var firefoxCapabilities = capabilities["moz:firefoxOptions", default: [:]] as! [String : Any]
        firefoxCapabilities.updateValue(value, forKey: key)
        
        capabilities["moz:firefoxOptions"] = firefoxCapabilities
        
        return WebDriver.Firefox(capabilities: capabilities)
    }
    
    internal func appendingFirefoxArg(arg: String) -> WebDriver.Firefox {
        var capabilities = self.capabilities // copy
        var firefoxCapabilities = capabilities["moz:firefoxOptions", default: [:]] as! [String : Any]
        var args = firefoxCapabilities["args", default: []] as! [String]
        args.append(arg)
        
        firefoxCapabilities["args"] = args
        capabilities["moz:firefoxOptions"] = firefoxCapabilities
        
        return WebDriver.Firefox(capabilities: capabilities)
    }
    
    
    /// Absolute path to the custom Firefox binary to use.
    ///
    /// On macOS you may either give the path to the application bundle, i.e. `/Applications/Firefox.app`, or the absolute path to the executable binary inside this bundle, for example `/Applications/Firefox.app/Contents/MacOS/firefox-bin`.
    func binary(location: FinderItem) -> WebDriver.Firefox {
        self.appendingFirefoxCapability(key: "binary", value: location.path)
    }
    
    
    /// Open new instance, not a new window in running instance, which allows multiple copies of application to be open at a time.
    func newInstance() -> WebDriver.Firefox {
        self.appendingFirefoxArg(arg: "-new-instance")
    }
    
    /// Start with the profile with the given path.
    func profile(location: FinderItem) -> WebDriver.Firefox {
        self.appendingFirefoxArg(arg: "-profile")
            .appendingFirefoxArg(arg: location.path)
    }
    
    /// Bypass profile manager and launch application with the profile named `name`.
    ///
    /// `profile_name` is case sensitive. If you don't specify a profile name then the profile manager is opened instead.
    func profile(named name: String) -> WebDriver.Firefox {
        self.appendingFirefoxArg(arg: "-P")
            .appendingFirefoxArg(arg: "\"\(name)\"")
    }
    
    /// Make this instance the active application.
    func foreground() -> WebDriver.Firefox {
        self.appendingFirefoxArg(arg: "-foreground")
    }
    
    /// Runs Firefox in headless mode, which is very useful for purposes such as debugging and automated testing.
    func headless() -> WebDriver.Firefox {
        self.appendingFirefoxArg(arg: "-headless")
    }
    
    /// Open URL in a new tab.
    func new(tab: URL) -> WebDriver.Firefox {
        self.appendingFirefoxArg(arg: "-new-tab")
            .appendingFirefoxArg(arg: tab.absoluteString)
    }
    
    /// Open URL in a new window.
    func new(window: URL) -> WebDriver.Firefox {
        self.appendingFirefoxArg(arg: "-new-window")
            .appendingFirefoxArg(arg: window.absoluteString)
    }
    
    /// Opens Firefox in permanent private browsing mode.
    func `private`() -> WebDriver.Firefox {
        self.appendingFirefoxArg(arg: "-private")
    }
    
    /// Opens a new private browsing window in an existing instance of Firefox
    func privateWindow() -> WebDriver.Firefox {
        self.appendingFirefoxArg(arg: "-private-window")
    }
    
}
