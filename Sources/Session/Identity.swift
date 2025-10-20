//
//  Identity.swift
//  WebDriver
//
//  Created by Vaida on 2025-10-20.
//


/// The identity, used to distinguish a value.
public struct Identity: Equatable, Sendable {
    
    /// The id assigned by WebDriver protocol.
    public internal(set) var id: String
    
    /// The context from which it was created.
    public let creation: SwiftContext
    
}
