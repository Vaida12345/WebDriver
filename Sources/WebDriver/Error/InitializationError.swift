//
//  InitializationError.swift
//  WebDriver
//
//  Created by Vaida on 2026-05-02.
//

import Essentials


extension WebDriver {
    
    public struct InitializationError: GenericError {
        public var message: String {
            "This web driver is not available."
        }
    }
    
}
