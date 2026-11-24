//
//  Chrome.swift
//  WebDriver
//
//  Created by Claude on 11/25/26.
//

import Foundation
import FinderItem


extension WebDriver {

    /// The Chrome WebDriver.
    ///
    /// > Note:
    /// > To use Chrome, install `chromedriver`, for example with
    /// > ```sh
    /// >  $ brew install --cask chromedriver
    /// > ```
    /// > or from Chrome for Testing.
    ///
    /// > Important:
    /// > `chromedriver` only drives the Chrome with the same major version. With other versions, starting a session fails with ``WebDriverError`` with ``WebDriverError/ErrorCode/session_not_created``, whose message names both versions. Update Chrome, or install the matching `chromedriver`.
    ///
    /// Other Chromium browsers, such as Brave, can be driven with ``binary(location:)``, using the `chromedriver` that matches their Chromium version.
    public struct Chrome: WebDriverProtocol, @unchecked Sendable {

        public fileprivate(set) var capabilities: [String : Any]

        public fileprivate(set) var flags: WebDriverInitializationFlags


        public func startSession(urlSessionConfiguration: URLSessionConfiguration = .ephemeral, fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function) async throws -> Session {
            guard let chromeDriverPath = Chrome.chromeDriverPath else { throw InitializationError.driverNotAvailable }

            // Each launch gets its own copy of the user data folder, as Chrome refuses one that is in use. The copy is deleted once chromedriver and Chrome have exited.
            var driver = self
            var temporaryProfile: String?
            if self.flags.contains(.copyProfileOnLaunch), let template = self.chromeArg(prefix: "--user-data-dir") {
                let copy = try makeTemporaryProfile(from: template)
                temporaryProfile = copy
                driver = try driver.settingChromeArg(prefix: "--user-data-dir", value: copy)
            }

            // chromedriver only accepts local connections by default.
            let launcher = try await DriverProcessLauncher(
                driver: driver,
                name: "chromedriver",
                executable: chromeDriverPath,
                arguments: { port in ["--port=\(port)"] },
                onExit: { [temporaryProfile] in
                    removeTemporaryProfile(at: temporaryProfile)
                }
            )
            return try await launcher.startSession(context: SwiftContext(fileID: fileID, line: line, function: function), invoker: #function, urlSessionConfiguration: urlSessionConfiguration)
        }


        public init(capabilities: [String : Any], flags: WebDriverInitializationFlags) throws(InitializationError) {
            self.capabilities = capabilities
            self.flags = flags
        }

        /// Initialize the WebDriver.
        public init() throws(InitializationError) {
            try self.init(capabilities: ["browserName": "chrome", "goog:chromeOptions": [String : Any]()], flags: [])
        }

        /// Whether `chromedriver` is installed on this device.
        ///
        /// This does not check whether its version matches the installed Chrome.
        public static var isAvailable: Bool {
            Self.chromeDriverPath != nil
        }

        /// Resolves the `chromedriver` executable path used to start Chrome sessions.
        ///
        /// Resolution order:
        /// 1. `WEBDRIVER_CHROME_PATH` environment variable.
        /// 2. The directories in `PATH`.
        /// 3. Common macOS install paths, as apps launched from Finder get a minimal `PATH`.
        static var chromeDriverPath: String? {
            let environment = DriverEnvironment.current
            let fileManager = FileManager.default

            if let override = environment["WEBDRIVER_CHROME_PATH"],
               !override.isEmpty,
               fileManager.isExecutableFile(atPath: override) {
                return override
            }

            let searchPaths = (environment["PATH"] ?? "")
                .split(separator: ":")
                .map { "\($0)/chromedriver" }
            let fallbackPaths = [
                "/opt/homebrew/bin/chromedriver",
                "/usr/local/bin/chromedriver"
            ]

            return (searchPaths + fallbackPaths).first(where: { fileManager.isExecutableFile(atPath: $0) })
        }

    }

}


public extension WebDriver.Chrome {

    // MARK: - Options

    internal func appendingChromeOption(key: String, value: Any) throws(WebDriver.InitializationError) -> WebDriver.Chrome {
        var capabilities = self.capabilities // copy
        guard var chromeOptions = capabilities["goog:chromeOptions", default: [String : Any]()] as? [String : Any] else { throw .internalCapabilityCastError }
        chromeOptions[key] = value
        capabilities["goog:chromeOptions"] = chromeOptions
        return try WebDriver.Chrome(capabilities: capabilities, flags: self.flags)
    }

    /// The switches passed to Chrome.
    internal func chromeArgs() throws(WebDriver.InitializationError) -> [String] {
        guard let chromeOptions = self.capabilities["goog:chromeOptions", default: [String : Any]()] as? [String : Any],
              let args = chromeOptions["args", default: [String]()] as? [String] else { throw .internalCapabilityCastError }
        return args
    }

    internal func settingChromeArgs(_ args: [String]) throws(WebDriver.InitializationError) -> WebDriver.Chrome {
        try self.appendingChromeOption(key: "args", value: args)
    }

    /// Sets the switch `prefix=value`, replacing any switch with the same prefix, such as `--window-size`.
    internal func settingChromeArg(prefix: String, value: String?) throws(WebDriver.InitializationError) -> WebDriver.Chrome {
        var args = try self.chromeArgs().filter { $0 != prefix && !$0.hasPrefix(prefix + "=") }
        if let value {
            args.append("\(prefix)=\(value)")
        }
        return try self.settingChromeArgs(args)
    }

    /// The value of the switch `prefix=value`, if set.
    internal func chromeArg(prefix: String) -> String? {
        guard let args = try? self.chromeArgs(),
              let arg = args.last(where: { $0.hasPrefix(prefix + "=") }) else { return nil }
        return String(arg.dropFirst(prefix.count + 1))
    }


    // MARK: - Public modifiers

    /// Runs Chrome without a visible window.
    func headless(_ isEnabled: Bool = true) throws(WebDriver.InitializationError) -> WebDriver.Chrome {
        try self.settingChromeArg(prefix: "--headless", value: isEnabled ? "new" : nil)
    }

    /// Sets the size of the browser window, in points.
    func windowSize(width: Int, height: Int) throws(WebDriver.InitializationError) -> WebDriver.Chrome {
        try self.settingChromeArg(prefix: "--window-size", value: "\(width),\(height)")
    }

    /// Adds command-line switches for Chrome, such as `--lang=en-US`.
    func arguments(_ switches: [String]) throws(WebDriver.InitializationError) -> WebDriver.Chrome {
        try self.settingChromeArgs(self.chromeArgs() + switches)
    }

    /// The Chrome, or other Chromium browser, to drive.
    ///
    /// On macOS you may either give the path to the application bundle, such as `/Applications/Brave Browser.app`, or the absolute path to the executable inside it.
    func binary(location: FinderItem) throws(WebDriver.InitializationError) -> WebDriver.Chrome {
        var path = location.path
        if path.hasSuffix(".app") {
            let name = (path as NSString).lastPathComponent.dropLast(".app".count)
            path = "\(path)/Contents/MacOS/\(name)"
        }
        return try self.appendingChromeOption(key: "binary", value: path)
    }


    // MARK: - Profiles

    /// Starts with a copy of the user data folder at `location`.
    ///
    /// Each session started from this driver gets its own temporary copy of the folder, which is deleted when the session ends. This avoids Chrome refusing a folder that a running Chrome uses, and conflicts between sessions. Replaces any profile set before.
    ///
    /// - Parameters:
    ///   - location: The user data folder, which holds one or more profiles. Chrome's own is `~/Library/Application Support/Google/Chrome`, which can be large to copy.
    ///   - directory: The profile folder inside `location` to use, such as `Default` or `Profile 1`. When `nil`, Chrome uses `Default`.
    func profile(location: FinderItem, directory: String? = nil) throws(WebDriver.InitializationError) -> WebDriver.Chrome {
        var new = try self.settingChromeArg(prefix: "--user-data-dir", value: location.path)
            .settingChromeArg(prefix: "--profile-directory", value: directory)
        new.flags.insert(.copyProfileOnLaunch)
        return new
    }

    /// Starts with the user data folder at `location`, without copying it.
    ///
    /// Changes made during the session, such as cookies, are kept in the folder. Replaces any profile set before.
    ///
    /// - Warning: Chrome refuses a folder that is already in use, for example by a running Chrome, and starting the session fails with ``WebDriverError``.
    func profile(noCopying location: FinderItem, directory: String? = nil) throws(WebDriver.InitializationError) -> WebDriver.Chrome {
        var new = try self.settingChromeArg(prefix: "--user-data-dir", value: location.path)
            .settingChromeArg(prefix: "--profile-directory", value: directory)
        new.flags.remove(.copyProfileOnLaunch)
        return new
    }

}
