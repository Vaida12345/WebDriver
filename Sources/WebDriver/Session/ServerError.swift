//
//  ServerError.swift
//  WebDriver
//
//  Created by Vaida on 2/26/25.
//

import Foundation
import Essentials


public struct ServerError: GenericError {
    
    public let code: Int
    
    public let title: String?
    
    public let message: String
    
    public let stackTrace: String
    
}
