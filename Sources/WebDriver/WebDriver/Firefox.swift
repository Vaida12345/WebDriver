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
        /// 2. The directories in `PATH`.
        /// 3. Common macOS install paths, as apps launched from Finder get a minimal `PATH`.
        static var geckoDriverPath: String? {
            let environment = ProcessInfo.processInfo.environment
            let fileManager = FileManager.default
            
            if let override = environment["WEBDRIVER_GECKO_PATH"],
               !override.isEmpty,
               fileManager.isExecutableFile(atPath: override) {
                return override
            }
            
            let searchPaths = (environment["PATH"] ?? "")
                .split(separator: ":")
                .map { "\($0)/geckodriver" }
            let fallbackPaths = [
                "/opt/homebrew/bin/geckodriver",
                "/usr/local/bin/geckodriver"
            ]
            
            return (searchPaths + fallbackPaths).first(where: { fileManager.isExecutableFile(atPath: $0) })
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
    
    /// The arguments passed to Firefox.
    internal func firefoxArgs() throws(WebDriver.InitializationError) -> [String] {
        guard let firefoxCapabilities = self.capabilities["moz:firefoxOptions", default: [:]] as? [String : Any],
              let args = firefoxCapabilities["args", default: []] as? [String] else { throw .internalCapabilityCastError }
        return args
    }

    internal func settingFirefoxArgs(_ args: [String]) throws(WebDriver.InitializationError) -> WebDriver.Firefox {
        var capabilities = self.capabilities // copy
        guard var firefoxCapabilities = capabilities["moz:firefoxOptions", default: [:]] as? [String : Any] else { throw .internalCapabilityCastError }

        firefoxCapabilities["args"] = args
        capabilities["moz:firefoxOptions"] = firefoxCapabilities

        return try WebDriver.Firefox(capabilities: capabilities, flags: flags)
    }

    internal func appendingFirefoxArg(arg: String) throws(WebDriver.InitializationError) -> WebDriver.Firefox {
        try self.settingFirefoxArgs(self.firefoxArgs() + [arg])
    }

    /// Replaces the value following `option`, or appends `option` and `value` when `option` is absent.
    internal func settingFirefoxArg(_ option: String, value: String) throws(WebDriver.InitializationError) -> WebDriver.Firefox {
        var args = try self.firefoxArgs()
        if let index = args.firstIndex(of: option), index + 1 < args.count {
            args[index + 1] = value
        } else {
            args.append(contentsOf: [option, value])
        }
        return try self.settingFirefoxArgs(args)
    }

    /// The value following `option` in the Firefox arguments.
    internal func firefoxArg(after option: String) -> String? {
        guard let args = try? self.firefoxArgs(),
              let index = args.firstIndex(of: option),
              index + 1 < args.count else { return nil }
        return args[index + 1]
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
    /// Replaces any profile set before.
    ///
    /// - Warning: The API may return error when an instance with the same profile is open.
    func profile(noCopying location: FinderItem) throws(WebDriver.InitializationError) -> WebDriver.Firefox {
        var new = try self.settingFirefoxArg("-profile", value: location.path)
        new.flags.remove(.copyProfileOnLaunch)
        return new
    }

    /// Start with a copy of the profile with the given path.
    ///
    /// Each session started from this driver gets its own temporary copy of the profile, which is deleted when the session ends. This avoids conflicts with a running Firefox, or between sessions. Replaces any profile set before.
    func profile(location: FinderItem) throws(WebDriver.InitializationError) -> WebDriver.Firefox {
        var new = try self.settingFirefoxArg("-profile", value: location.path)
        new.flags.insert(.copyProfileOnLaunch)
        return new
    }

    /// Bypass profile manager and launch application with the profile named `name`.
    ///
    /// `profile_name` is case sensitive. If you don't specify a profile name then the profile manager is opened instead.
    func profile(named name: String) throws(WebDriver.InitializationError) -> WebDriver.Firefox {
        try self.appendingFirefoxArg(arg: "-P")
            .appendingFirefoxArg(arg: name)
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
