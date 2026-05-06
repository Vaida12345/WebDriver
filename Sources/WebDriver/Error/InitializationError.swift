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
        case exceededMaxRetries(Int)
        
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
            case .exceededMaxRetries(let maxRetries):
                "Failed to create a new web driver after \(maxRetries) retries."
            }
        }
    }
    
}
