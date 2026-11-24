//
//  DriverEnvironment.swift
//  WebDriver
//
//  Created by Claude on 11/25/26.
//

import Foundation


/// The environment variables used to locate the driver executables.
enum DriverEnvironment {

    /// Replaces the process environment within a task, so that tests can override driver paths without calling `setenv`, which is not safe while other threads read the environment.
    @TaskLocal static var override: [String : String]?

    /// The environment to read, ``override`` if set, otherwise the process environment.
    static var current: [String : String] {
        self.override ?? ProcessInfo.processInfo.environment
    }

}
