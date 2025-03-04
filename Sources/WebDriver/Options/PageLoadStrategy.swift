//
//  PageLoadStrategy.swift
//  WebDriver
//
//  Created by Vaida on 2/26/25.
//


/// The strategy used when loading webpages.
public enum PageLoadStrategy: String {
    
    /// Waits for the entire page to load, including subresources like scripts and images.
    case normal
    
    /// Waits only for the `DOMContentLoaded` event (ignores images, styles, and subresources).
    case eager
    
    /// Does not wait for the page to load; returns immediately after navigation.
    case none
    
}
