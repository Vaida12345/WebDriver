//
//  NewWindowResult.swift
//  WebDriver
//
//  Created by Vaida on 3/4/25.
//

import Essentials


public struct NewWindowResult: Sendable, Equatable {
    
    let handleID: WindowHandle
    
    let type: WindowType
    
    
    init(parser: JSONParser) throws {
        let value = try parser.object("value")
        self.handleID = try WindowHandle(id: value["handle"])
        self.type = try WindowType(rawValue: value["type"])!
    }
    
}
