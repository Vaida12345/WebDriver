//
//  ReadyState.swift
//  WebDriver
//
//  Created by Vaida on 5/3/25.
//


extension Session.Window {
    
    /// Reads and returns the current loading state of the page’s Document.
    public var readyState: ReadyState {
        get async throws {
            try await ReadyState(rawValue: self.execute("return document.readyState;")["value"])!
        }
    }
    
    
    /// Document Ready State.
    public enum ReadyState: String, Equatable, Sendable {
        
        /// The document is still loading
        case loading
        
        /// The document has been parsed (DOM is ready), but sub‐resources (images, stylesheets, frames) are still loading
        case interactive
        
        /// The document and all sub‐resources have finished loading
        case complete
        
    }
    
}
