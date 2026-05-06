//
//  Firefox.swift
//  WebDriver
//
//  Created by Vaida on 2/26/25.
//

import Foundation
import FinderItem
import ChildProcess


extension WebDriver {
    
    /// The Firefox WebDriver.
    ///
    /// > Note:
    /// > To use FireFox WebDriver, please ensure you have `geckodriver` installed, you can install it via
    /// > ```sh
    /// >  $ brew install geckodriver
    /// > ```
    public struct Firefox: WebDriverProtocol, @unchecked Sendable {
        
        public fileprivate(set) var capabilities: [String : Any]
        
        public fileprivate(set) var flags: WebDriverInitializationFlags
        
        
        public func startSession(urlSessionConfiguration: URLSessionConfiguration = .ephemeral, fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function) async throws -> Session {
            guard Firefox.isAvailable else { throw InitializationError.driverNotAvailable }
            
            let launcher = try await GeckoLauncher(driver: self)
            return try await Session(launcher: launcher, context: SwiftContext(fileID: fileID, line: line, function: function), invoker: #function, urlSessionConfiguration: urlSessionConfiguration)
        }
        
        
        public init(capabilities: [String : Any], flags: WebDriverInitializationFlags) throws(InitializationError) {
            self.capabilities = capabilities
            self.flags = flags
        }
        
        /// Initialize the WebDriver.
        public init() throws(InitializationError) {
            try self.init(capabilities: [:], flags: [])
        }
        
        /// Whether `geckodriver` is installed on local device.
        ///
        /// > Note:
        /// > To use FireFox WebDriver, please ensure you have `geckodriver` installed, you can install it via
        /// > ```sh
        /// >  $ brew install geckodriver
        /// > ```
        public static var isAvailable: Bool {
            Self.geckoDriverPath != nil
        }

        /// Resolves the `geckodriver` executable path used to start Firefox sessions.
        ///
        /// Resolution order:
        /// 1. `WEBDRIVER_GECKO_PATH` environment variable.
        /// 2. Common macOS install paths.
        static var geckoDriverPath: String? {
            get {
                if let override = ProcessInfo.processInfo.environment["WEBDRIVER_GECKO_PATH"],
                   !override.isEmpty,
                   FileManager.default.isExecutableFile(atPath: override) {
                    return override
                }
                
                let fallbackPaths = [
                    "/opt/homebrew/bin/geckodriver",
                    "/usr/local/bin/geckodriver"
                ]
                
                return fallbackPaths.first(where: { FileManager.default.isExecutableFile(atPath: $0) })
            }
        }

        /// Finds `geckodriver` from the current process `PATH`.
        private static func geckoDriverPathFromPATH() async -> String? {
            do {
                let (path, _) = try await ChildProcess.run(.name("which"), arguments: ["geckodriver"])
                
                guard let output = path?.trimmingCharacters(in: .whitespacesAndNewlines),
                      !output.isEmpty,
                      FileManager.default.isExecutableFile(atPath: output) else { return nil }
                return output
            } catch {
                return nil
            }
        }
        
    }
    
}


public extension WebDriver.Firefox {
    
    internal func appendingFirefoxCapability(key: String, value: String) throws(WebDriver.InitializationError) -> WebDriver.Firefox {
        var capabilities = self.capabilities // copy
        guard var firefoxCapabilities = capabilities["moz:firefoxOptions", default: [:]] as? [String : Any] else { throw .internalCapabilityCastError }
        firefoxCapabilities.updateValue(value, forKey: key)
        
        capabilities["moz:firefoxOptions"] = firefoxCapabilities
        
        return try WebDriver.Firefox(capabilities: capabilities, flags: flags)
    }
    
    internal func appendingFirefoxArg(arg: String) throws(WebDriver.InitializationError) -> WebDriver.Firefox {
        var capabilities = self.capabilities // copy
        guard var firefoxCapabilities = capabilities["moz:firefoxOptions", default: [:]] as? [String : Any] else { throw .internalCapabilityCastError }
        guard var args = firefoxCapabilities["args", default: []] as? [String] else { throw .internalCapabilityCastError }
        args.append(arg)
        
        firefoxCapabilities["args"] = args
        capabilities["moz:firefoxOptions"] = firefoxCapabilities
        
        return try WebDriver.Firefox(capabilities: capabilities, flags: flags)
    }
    
    
    /// Absolute path to the custom Firefox binary to use.
    ///
    /// On macOS you may either give the path to the application bundle, i.e. `/Applications/Firefox.app`, or the absolute path to the executable binary inside this bundle, for example `/Applications/Firefox.app/Contents/MacOS/firefox-bin`.
    func binary(location: FinderItem) throws(WebDriver.InitializationError) -> WebDriver.Firefox {
        try self.appendingFirefoxCapability(key: "binary", value: location.path)
    }
    
    
    /// Open new instance, not a new window in running instance, which allows multiple copies of application to be open at a time.
    func newInstance() throws(WebDriver.InitializationError) -> WebDriver.Firefox {
        try self.appendingFirefoxArg(arg: "-new-instance")
    }
    
    /// Start with the profile with the given path.
    ///
    /// - Warning: The API may return error when an instance with the same profile is open.
    func profile(noCopying location: FinderItem) throws(WebDriver.InitializationError) -> WebDriver.Firefox {
        try self.appendingFirefoxArg(arg: "-profile")
            .appendingFirefoxArg(arg: location.path)
    }
    
    /// Start with the profile with the given path.
    ///
    /// This implementation will create a temp copy of the profile to avoid conflicts.
    func profile(location: FinderItem) async throws -> WebDriver.Firefox {
        let temp = try FinderItem.temporaryDirectory(intent: .general)/"\(UUID()).tempprofile"
        try location.copy(to: temp)
        var new = try self.appendingFirefoxArg(arg: "-profile").appendingFirefoxArg(arg: temp.path)
        new.flags.insert(.deleteProfileAfterUse)
        return new
    }
    
    /// Bypass profile manager and launch application with the profile named `name`.
    ///
    /// `profile_name` is case sensitive. If you don't specify a profile name then the profile manager is opened instead.
    func profile(named name: String) throws(WebDriver.InitializationError) -> WebDriver.Firefox {
        try self.appendingFirefoxArg(arg: "-P")
            .appendingFirefoxArg(arg: "\"\(name)\"")
    }
    
    /// Make this instance the active application.
    func foreground() throws(WebDriver.InitializationError) -> WebDriver.Firefox {
        try self.appendingFirefoxArg(arg: "-foreground")
    }
    
    /// Runs Firefox in headless mode, which is very useful for purposes such as debugging and automated testing.
    func headless() throws(WebDriver.InitializationError) -> WebDriver.Firefox {
        try self.appendingFirefoxArg(arg: "-headless")
    }
    
    /// Open URL in a new tab.
    func new(tab: URL) throws(WebDriver.InitializationError) -> WebDriver.Firefox {
        try self.appendingFirefoxArg(arg: "-new-tab")
            .appendingFirefoxArg(arg: tab.absoluteString)
    }
    
    /// Open URL in a new window.
    func new(window: URL) throws(WebDriver.InitializationError) -> WebDriver.Firefox {
        try self.appendingFirefoxArg(arg: "-new-window")
            .appendingFirefoxArg(arg: window.absoluteString)
    }
    
    /// Opens Firefox in permanent private browsing mode.
    func `private`() throws(WebDriver.InitializationError) -> WebDriver.Firefox {
        try self.appendingFirefoxArg(arg: "-private")
    }
    
    /// Opens a new private browsing window in an existing instance of Firefox
    func privateWindow() throws(WebDriver.InitializationError) -> WebDriver.Firefox {
        try self.appendingFirefoxArg(arg: "-private-window")
    }
    
}
