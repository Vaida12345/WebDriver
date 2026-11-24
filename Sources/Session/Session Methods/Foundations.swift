//
//  Foundations.swift
//  WebDriver
//
//  Created by Vaida on 3/4/25.
//

import Essentials
import JSONParser


extension Session {
    
    /// Close the connection.
    ///
    /// Deletes the session, which closes the browser, then stops the driver this session launched. The driver is stopped even if deleting the session fails.
    ///
    /// The session can no longer be used afterward, as its connection is invalidated. A session dropped without calling this keeps its connection, and its driver until the launcher is released.
    public func close(fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function) async throws {
        do {
            let _ = try await self.data(.delete, "session/\(id)", data: nil,
                                        context: SwiftContext(fileID: fileID, line: line, function: function),
                                        origin: .session(self),
                                        invoker: #function)
        } catch {
            self.session.finishTasksAndInvalidate()
            await self.launcher.stop()
            throw error
        }
        self.session.finishTasksAndInvalidate()
        await self.launcher.stop()
    }
    
    
    public func status(fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function) async throws -> Status {
        let (data, _) = try await self.data(.get, "status", data: nil,
                                            context: SwiftContext(fileID: fileID, line: line, function: function),
                                            origin: .session(self),
                                            invoker: #function)
        
        return try Status(parser: JSONParser(data: data))
    }
    
}
