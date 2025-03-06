//
//  Foundations.swift
//  WebDriver
//
//  Created by Vaida on 3/4/25.
//

import Essentials


extension Session {
    
    /// Close the connection.
    public func close() async throws {
        let _ = try await self.data(.delete, "session/\(id)", data: nil)
        self.launcher.stop()
    }
    
    
    public func status() async throws -> SessionStatus {
        let (data, _) = try await self.data(.get, "status", data: nil)
        
        return try SessionStatus(parser: JSONParser(data: data))
    }
    
}
