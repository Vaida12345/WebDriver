//
//  Render.swift
//  WebDriver
//
//  Created by Vaida on 3/7/25.
//

import PDFKit
import Essentials
import Foundation
import JSONParser


extension Session.Window {
    
    /// Renders the current page as a PDF document.
    ///
    /// This function triggers the WebDriver `print` command to generate a PDF of the current page.
    /// The resulting PDF is returned as a `PDFDocument` object.
    ///
    /// - Parameters:
    ///   - orientation: The page orientation.
    ///   - scale: The scaling factor for page rendering ( valid range: `0.1` to `2.0`).
    ///   - includesBackground: Whether to include background graphics in the PDF.
    ///   - width: The paper width in inches.
    ///   - height: The paper height in inches.
    ///   - scaleToFit: Whether to shrink content to fit within the page dimensions.
    ///   - margin: The margins for the PDF.
    ///
    /// - Returns: A `PDFDocument` representing the printed page.
    ///
    /// > First Responder:
    /// > The first responder is switched to `self`.
    public func render(
        orientation: PageOrientation = .portrait,
        scale: Double = 1.0,
        includesBackground: Bool = false,
        width: Double = 21.59,
        height: Double = 27.94,
        scaleToFit: Bool = true,
        margin: Margin = Margin(),
        fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function
    ) async throws -> sending PDFDocument {
        try await self.becomeFirstResponder(fileID: fileID, line: line, function: function)
        
        let (result, _) = try await self.session.data(
            .post,
            "session/\(self.session.id)/print",
            json: [
                "orientation": orientation.rawValue,
                "scale": scale,
                "background": includesBackground,
                "width": width,
                "height": height,
                "shrinkToFit": scaleToFit,
                "margin": [
                    "top": margin.top,
                    "bottom": margin.bottom,
                    "left": margin.leading,
                    "right": margin.trailing
                ]
            ],
            context: SwiftContext(fileID: fileID, line: line, function: function),
            origin: .window(self),
            invoker: #function
        )
        let data = try decodeBase64(from: JSONParser(data: result), expected: "a PDF document")
        guard let document = PDFDocument(data: data) else { throw Session.SessionError.undecodableContent(expected: "a PDF document") }
        return document
    }
    
    
    public enum PageOrientation: String {
        case landscape
        case portrait
    }
    
    public struct Margin {
        public let top: Double
        public let bottom: Double
        public let leading: Double
        public let trailing: Double
        
        public init(top: Double = 1, bottom: Double = 1, leading: Double = 1, trailing: Double = 1) {
            self.top = top
            self.bottom = bottom
            self.leading = leading
            self.trailing = trailing
        }
    }
    
}
