//
//  Window Position.swift
//  WebDriver
//
//  Created by Vaida on 3/5/25.
//

import Essentials
import CoreGraphics


extension Session.Window {
    
    /// The window rect.
    ///
    /// > First Responder:
    /// > The first responder is switched to `self`.
    public var frame: CGRect {
        get async throws {
            try await self.becomeFirstResponder()
            
            let (data, _) = try await self.session.data(.get, "session/\(self.session.id)/window/rect", data: nil)
            let parser = try JSONParser(data: data).object("value")
            
            return try CGRect(x: parser["x", .numeric],
                              y: parser["y", .numeric],
                              width: parser["width", .numeric],
                              height: parser["height", .numeric])
        }
    }
    
}
