//
//  PersistenceObject.swift
//  SwiftData
//
//  Created by Hiral Naik on 8/6/25.
//

import Foundation

public protocol PersistenceObject: Sendable {
    init?(persistenceObj: Data)
    func key() -> String
    func persistenceObject() -> Data
}
