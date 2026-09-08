//
//  PersistenceError.swift
//  SwiftData
//
//  Created by Hiral Naik on 8/6/25.
//

public enum PersistenceError: Error, Sendable {
    case persistenceFailed
    case storeFailed
    case retrieveFailed
    case removeFailed
    case invalidConfiguration(error: Error)
    
    // Custom Sendable conformance check for the associated value
    // Note: Error types in Swift are implicitly Sendable when possible
}
