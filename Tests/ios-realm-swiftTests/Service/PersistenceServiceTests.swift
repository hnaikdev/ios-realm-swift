//
//  PersistenceServiceTests.swift
//  SwiftData
//
//  Created by Hiral Naik on 8/25/25.
//

import Testing
import Foundation
@testable import ios_realm_swift

@Suite("PersistenceService Tests")
struct PersistenceServiceTests {
    
    // MARK: - Helper Methods
    
    private func cleanupTestObject(_ service: PersistenceService, id: String) {
        let obj = try? TestModel(id: id, name: "cleanup")
        if let obj = obj {
            try? service.remove(obj)
        }
    }
    
    // MARK: - Store Tests
    
    @Test("Store and retrieve object from Realm")
    func storeAndRetrieve() async throws {
        let realmService = PersistenceService()
        let testId = "test-store-\(UUID().uuidString)"
        let obj = try TestModel(id: testId, name: "Alice")
        
        try realmService.store(obj)
        
        let retrievedObj: TestModel? = try realmService.retrieve(testId)
        #expect(retrievedObj != nil, "Object should be retrieved")
        #expect(retrievedObj?.id == testId, "ID should match")
        #expect(retrievedObj?.name == "Alice", "Name should match")
        
        // Cleanup
        try? realmService.remove(obj)
    }
    
    @Test("Store object with large data")
    func storeLargeObject() async throws {
        let realmService = PersistenceService()
        let testId = "test-large-\(UUID().uuidString)"
        let largeName = String(repeating: "A", count: 1000)
        let obj = try TestModel(id: testId, name: largeName)
        
        try realmService.store(obj)
        
        let retrievedObj: TestModel? = try realmService.retrieve(testId)
        #expect(retrievedObj != nil, "Large object should be retrieved")
        #expect(retrievedObj?.name.count == 1000, "Large name should be preserved")
        
        // Cleanup
        try? realmService.remove(obj)
    }
    
    @Test("Store fails when object exceeds max size")
    func storeOversizedObjectFails() async throws {
        let realmService = PersistenceService()
        // Create object larger than 10MB
        let testId = "test-huge-\(UUID().uuidString)"
        let hugeName = String(repeating: "X", count: 11 * 1024 * 1024)
        let obj = try TestModel(id: testId, name: hugeName)
        
        var didThrow = false
        do {
            try realmService.store(obj)
        } catch PersistenceError.storeFailed {
            didThrow = true
        } catch {
            Issue.record("Expected PersistenceError.storeFailed, got \(error)")
        }
        
        #expect(didThrow, "Should throw storeFailed error for oversized object")
    }
    
    // MARK: - Update Tests
    
    @Test("Update and retrieve object from Realm")
    func updateAndRetrieve() async throws {
        let realmService = PersistenceService()
        let testId = "test-update-\(UUID().uuidString)"
        let obj = try TestModel(id: testId, name: "Alice")
        
        try realmService.store(obj)
        
        let retrievedObj: TestModel? = try realmService.retrieve(testId)
        #expect(retrievedObj?.name == "Alice", "Initial name should be Alice")
        
        // Update the object
        var updatedObj = retrievedObj!
        updatedObj.name = "Bob"
        try realmService.store(updatedObj)
        
        let finalObj: TestModel? = try realmService.retrieve(testId)
        #expect(finalObj != nil, "Updated object should exist")
        #expect(finalObj?.name == "Bob", "Name should be updated to Bob")
        
        // Cleanup
        try? realmService.remove(finalObj!)
    }
    
    // MARK: - Retrieve Multiple Tests
    
    @Test("Store and retrieve multiple objects from Realm")
    func storeAndRetrieveMultipleObjects() async throws {
        let realmService = PersistenceService()
        let prefix = "test-multi-\(UUID().uuidString)"
        
        let obj1 = try TestModel(id: "\(prefix)-1", name: "Alice")
        let obj2 = try TestModel(id: "\(prefix)-2", name: "Bob")
        let obj3 = try TestModel(id: "\(prefix)-3", name: "Charlie")
        
        try realmService.store(obj1)
        try realmService.store(obj2)
        try realmService.store(obj3)
        
        let objects: [TestModel] = try realmService.retrieve(objectOfType: TestModel.self)
        let filteredObjects = objects.filter { $0.id.hasPrefix(prefix) }
        #expect(filteredObjects.count == 3, "Should retrieve all 3 stored objects")
        
        let keysObjects: [TestModel] = try realmService.retrieve(["\(prefix)-1", "\(prefix)-2"])
        #expect(keysObjects.count == 2, "Should retrieve exactly 2 objects by keys")
        #expect(keysObjects.contains(where: { $0.id == "\(prefix)-1" }), "Should contain first object")
        #expect(keysObjects.contains(where: { $0.id == "\(prefix)-2" }), "Should contain second object")
        
        // Cleanup
        try? realmService.remove(obj1)
        try? realmService.remove(obj2)
        try? realmService.remove(obj3)
    }
    
    @Test("Retrieve by keys with some non-existent keys")
    func retrieveByKeysPartialMatch() async throws {
        let realmService = PersistenceService()
        let testId = "test-partial-\(UUID().uuidString)"
        
        let obj1 = try TestModel(id: testId, name: "Alice")
        try realmService.store(obj1)
        
        let objects: [TestModel] = try realmService.retrieve([testId, "non-existent-key-\(UUID().uuidString)"])
        #expect(objects.count == 1, "Should only retrieve the existing object")
        #expect(objects.first?.id == testId, "Retrieved object should match")
        
        // Cleanup
        try? realmService.remove(obj1)
    }
    
    @Test("Retrieve empty array when no objects match")
    func retrieveEmptyArray() async throws {
        let realmService = PersistenceService()
        
        let objects: [TestModel] = try realmService.retrieve([
            "totally-fake-key-\(UUID().uuidString)",
            "another-fake-key-\(UUID().uuidString)"
        ])
        #expect(objects.isEmpty, "Should return empty array for non-existent keys")
    }
    
    @Test("Retrieve all objects of specific type")
    func retrieveAllObjectsOfType() async throws {
        let realmService = PersistenceService()
        let prefix = "test-all-\(UUID().uuidString)"
        
        let obj1 = try TestModel(id: "\(prefix)-1", name: "Alice")
        let obj2 = try TestModel(id: "\(prefix)-2", name: "Bob")
        
        try realmService.store(obj1)
        try realmService.store(obj2)
        
        let allObjects: [TestModel] = try realmService.retrieve(objectOfType: TestModel.self)
        let ourObjects = allObjects.filter { $0.id.hasPrefix(prefix) }
        
        #expect(ourObjects.count == 2, "Should retrieve all objects of TestModel type")
        
        // Cleanup
        try? realmService.remove(obj1)
        try? realmService.remove(obj2)
    }
    
    // MARK: - Remove Tests
    
    @Test("Remove object from Realm")
    func removeObject() async throws {
        let realmService = PersistenceService()
        let testId = "test-remove-\(UUID().uuidString)"
        let obj = try TestModel(id: testId, name: "Alice")
        
        try realmService.store(obj)
        let retrievedObj: TestModel? = try realmService.retrieve(testId)
        
        #expect(retrievedObj != nil, "Object should exist before removal")
        #expect(retrievedObj?.name == "Alice", "Object data should be correct")
        
        try realmService.remove(obj)
        let removed: TestModel? = try realmService.retrieve(testId)
        
        #expect(removed == nil, "Object should not exist after removal")
    }
    
    @Test("Remove non-existent object throws error")
    func removeNonExistentObject() async throws {
        let realmService = PersistenceService()
        let testId = "non-existent-\(UUID().uuidString)"
        let obj = try TestModel(id: testId, name: "Ghost")
        
        var didThrow = false
        do {
            try realmService.remove(obj)
        } catch PersistenceError.removeFailed {
            didThrow = true
        } catch {
            Issue.record("Expected PersistenceError.removeFailed, got \(error)")
        }
        
        #expect(didThrow, "Should throw removeFailed error for non-existent object")
    }
    
    // MARK: - Retrieve Edge Cases
    
    @Test("Retrieve non-existent object returns nil")
    func retrieveNonexistent() async throws {
        let realmService = PersistenceService()
        let testId = "definitely-not-here-\(UUID().uuidString)"
        let obj: TestModel? = try realmService.retrieve(testId)
        
        #expect(obj == nil, "Non-existent object should return nil")
    }
    
    @Test("Retrieve with empty key returns nil")
    func retrieveEmptyKey() async throws {
        let realmService = PersistenceService()
        let obj: TestModel? = try realmService.retrieve("")
        
        #expect(obj == nil, "Empty key should return nil")
    }
    
    // MARK: - Concurrency Tests
    
    @Test("Concurrent writes to different objects")
    func concurrentWrites() async throws {
        let realmService = PersistenceService()
        let prefix = "concurrent-\(UUID().uuidString)"
        
        await withTaskGroup(of: Void.self) { group in
            for i in 0..<10 {
                group.addTask {
                    let obj = try! TestModel(id: "\(prefix)-\(i)", name: "Object \(i)")
                    try? realmService.store(obj)
                }
            }
        }
        
        // Small delay to ensure all writes complete
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // Verify all objects were stored
        let objects: [TestModel] = try realmService.retrieve(objectOfType: TestModel.self)
        let concurrentObjects = objects.filter { $0.id.hasPrefix(prefix) }
        #expect(concurrentObjects.count == 10, "All concurrent writes should succeed")
        
        // Cleanup
        for i in 0..<10 {
            let obj = try TestModel(id: "\(prefix)-\(i)", name: "Object \(i)")
            try? realmService.remove(obj)
        }
    }
    
    @Test("Concurrent reads are thread-safe")
    func concurrentReads() async throws {
        let realmService = PersistenceService()
        let testId = "concurrent-read-\(UUID().uuidString)"
        let obj = try TestModel(id: testId, name: "Concurrent Test")
        
        try realmService.store(obj)
        
        await withTaskGroup(of: TestModel?.self) { group in
            for _ in 0..<20 {
                group.addTask {
                    try? realmService.retrieve(testId)
                }
            }
            
            var successfulReads = 0
            for await result in group {
                if result != nil {
                    successfulReads += 1
                }
            }
            
            #expect(successfulReads == 20, "All concurrent reads should succeed")
        }
        
        // Cleanup
        try? realmService.remove(obj)
    }
    
    // MARK: - Data Integrity Tests
    
    @Test("Store preserves special characters in data")
    func storeSpecialCharacters() async throws {
        let realmService = PersistenceService()
        let testId = "test-special-\(UUID().uuidString)"
        let specialName = "Test 🚀 with émojis & spëcial çhars!"
        let obj = try TestModel(id: testId, name: specialName)
        
        try realmService.store(obj)
        
        let retrievedObj: TestModel? = try realmService.retrieve(testId)
        #expect(retrievedObj?.name == specialName, "Special characters should be preserved")
        
        // Cleanup
        try? realmService.remove(obj)
    }
    
    @Test("Store and retrieve empty name")
    func storeEmptyName() async throws {
        let realmService = PersistenceService()
        let testId = "test-empty-\(UUID().uuidString)"
        let obj = try TestModel(id: testId, name: "")
        
        try realmService.store(obj)
        
        let retrievedObj: TestModel? = try realmService.retrieve(testId)
        #expect(retrievedObj?.name == "", "Empty name should be preserved")
        
        // Cleanup
        try? realmService.remove(obj)
    }
}

