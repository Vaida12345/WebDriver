//
//  InitializationError.swift
//  WebDriver
//
//  Created by Vaida on 2026-05-02.
//

import Essentials


extension WebDriver {
    
    public enum InitializationError: GenericError {
        case driverNotAvailable
        case driverStartFailed
        case urlNotSupported
        case internalCapabilityCastError
        /// The driver failed to become ready after the given number of attempts. `output` holds the reason and the last lines of the driver's output.
        case exceededMaxRetries(Int, output: String)
        
        public var message: String {
            switch self {
            case .driverNotAvailable:
                "This web driver is not available."
            case .driverStartFailed:
                "Driver start failed."
            case .urlNotSupported:
                "This URL is not supported."
            case .internalCapabilityCastError:
                "Failed to cast the internal capability to the requested one."
            case .exceededMaxRetries(let maxRetries, let output):
                "Failed to start the web driver after \(maxRetries) attempts.\n\(output)"
            }
        }
    }
    
}
