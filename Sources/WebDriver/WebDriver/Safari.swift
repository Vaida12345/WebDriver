//
//  Safari.swift
//  WebDriver
//
//  Created by Claude on 11/24/26.
//

import Foundation


extension WebDriver {

    /// The Safari WebDriver.
    ///
    /// Safari's driver, `safaridriver`, comes with macOS, so nothing needs to be installed.
    ///
    /// > Important:
    /// > Remote automation must be allowed once before Safari can be controlled. Either run the following, which asks for an administrator password,
    /// > ```sh
    /// >  $ safaridriver --enable
    /// > ```
    /// > or turn on Allow Remote Automation in Safari's Develop menu. Until then, starting a session fails with ``WebDriverError``.
    ///
    /// Compared with Firefox:
    /// - Safari runs only one automation session at a time on a Mac. Starting another while one is open fails with ``WebDriverError``.
    /// - Safari has no headless mode; the session opens a visible window, which closes when the session is closed.
    /// - Firefox-only features, such as ``Session/Window-swift.struct/screenshot(fullPage:fileID:line:function:)`` with `fullPage`, fail with ``WebDriverError``.
    public struct Safari: WebDriverProtocol, @unchecked Sendable {

        public fileprivate(set) var capabilities: [String : Any]

        public fileprivate(set) var flags: WebDriverInitializationFlags


        public func startSession(urlSessionConfiguration: URLSessionConfiguration = .ephemeral, fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function) async throws -> Session {
            guard let safariDriverPath = Safari.safariDriverPath else { throw InitializationError.driverNotAvailable }

            // safaridriver has no option for the host; it listens on both IPv4 and IPv6 loopback.
            let launcher = try await DriverProcessLauncher(
                driver: self,
                name: "safaridriver",
                executable: safariDriverPath,
                arguments: { port in ["-p", port.description] }
            )
            return try await Session(launcher: launcher, context: SwiftContext(fileID: fileID, line: line, function: function), invoker: #function, urlSessionConfiguration: urlSessionConfiguration)
        }


        public init(capabilities: [String : Any], flags: WebDriverInitializationFlags) throws(InitializationError) {
            self.capabilities = capabilities
            self.flags = flags
        }

        /// Initialize the WebDriver.
        public init() throws(InitializationError) {
            try self.init(capabilities: ["browserName": "safari"], flags: [])
        }

        /// Whether `safaridriver` is available on this device.
        ///
        /// This does not check whether remote automation is allowed.
        public static var isAvailable: Bool {
            Self.safariDriverPath != nil
        }

        /// Resolves the `safaridriver` executable path used to start Safari sessions.
        ///
        /// Resolution order:
        /// 1. `WEBDRIVER_SAFARI_PATH` environment variable.
        /// 2. `/usr/bin/safaridriver`, which comes with macOS.
        static var safariDriverPath: String? {
            let fileManager = FileManager.default

            if let override = ProcessInfo.processInfo.environment["WEBDRIVER_SAFARI_PATH"],
               !override.isEmpty,
               fileManager.isExecutableFile(atPath: override) {
                return override
            }

            let path = "/usr/bin/safaridriver"
            return fileManager.isExecutableFile(atPath: path) ? path : nil
        }

    }

}


public extension WebDriver.Safari {

    /// Opens Web Inspector for the session's window when the session starts.
    ///
    /// Useful when debugging the pages and scripts that the session runs.
    func automaticInspection(_ isEnabled: Bool = true) throws(WebDriver.InitializationError) -> WebDriver.Safari {
        try self.appendingCapability(key: "safari:automaticInspection", value: isEnabled)
    }

    /// Starts a timeline recording in Web Inspector when the session starts.
    ///
    /// Useful when measuring the performance of the pages that the session opens.
    func automaticProfiling(_ isEnabled: Bool = true) throws(WebDriver.InitializationError) -> WebDriver.Safari {
        try self.appendingCapability(key: "safari:automaticProfiling", value: isEnabled)
    }

}
