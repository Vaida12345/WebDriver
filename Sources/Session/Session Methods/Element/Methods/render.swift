//
//  render.swift
//  WebDriver
//
//  Created by Vaida on 3/7/25.
//

import Foundation
import NativeImage


extension Element {
    
    /// Captures a screenshot of a specific element on the page.
    ///
    /// This endpoint takes a screenshot of the given element and returns it as a base64-encoded PNG image.
    ///
    /// - Important: Ensure that the element is visible before calling this endpoint.
    ///
    /// - Note: The screenshot will be cropped to the element's bounding box.
    public func screenshot() async throws -> sending NativeImage {
        let parser = try await self.parser(.get, "screenshot")!
        let base64 = try parser["value"]
        let data = Data(base64Encoded: base64)!
        return NativeImage(data: data)!
    }
    
}
