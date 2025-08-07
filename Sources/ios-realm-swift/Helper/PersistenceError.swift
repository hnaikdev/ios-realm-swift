//
//  PersistenceError.swift
//  SwiftData
//
//  Created by Hiral Naik on 8/6/25.
//

public enum PersistenceError: Error {
    case persistenceFailed
    case storeFailed
    case retrieveFailed
    case removeFailed
    case invalidConfiguration(error: Error)
}
