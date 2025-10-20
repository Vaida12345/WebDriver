//
//  Foundations.swift
//  WebDriver
//
//  Created by Vaida on 3/4/25.
//

import Essentials


extension Session {
    
    /// Close the connection.
    public func close(fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function) async throws {
        let _ = try await self.data(.delete, "session/\(id)", data: nil,
                                    context: SwiftContext(fileID: fileID, line: line, function: function),
                                    origin: .session(self),
                                    invoker: #function)
        self.launcher.stop()
    }
    
    
    public func status(fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function) async throws -> Status {
        let (data, _) = try await self.data(.get, "status", data: nil,
                                            context: SwiftContext(fileID: fileID, line: line, function: function),
                                            origin: .session(self),
                                            invoker: #function)
        
        return try Status(parser: JSONParser(data: data))
    }
    
}
