//
//  AsyncPersistenceServiceTests.swift
//  SwiftData
//
//  Created by Hiral Naik on 8/25/25.
//

import Testing
import Foundation
@testable import ios_realm_swift

@Suite("AsyncPersistenceService Tests")
struct AsyncPersistenceServiceTests {
    
    // MARK: - Helper Extensions
    
    /// Generic helper to convert async persistence operations with single result to async/await
    private func awaitAsyncOperation<T: Sendable>(
        _ operation: @escaping (@escaping @Sendable (T) -> Void) -> Void
    ) async -> T {
        await withCheckedContinuation { continuation in
            operation { result in
                continuation.resume(returning: result)
            }
        }
    }
    
    /// Generic helper for operations that return an error
    private func awaitStore<P: PersistenceObject>(
        _ service: AsyncPersistenceService,
        _ object: P
    ) async -> PersistenceError? {
        await withCheckedContinuation { (continuation: CheckedContinuation<PersistenceError?, Never>) in
            service.store(object) { error in
                continuation.resume(returning: error)
            }
        }
    }
    
    /// Generic helper for operations that return an optional object and error
    private func awaitRetrieve<P: PersistenceObject>(
        _ service: AsyncPersistenceService,
        _ key: String
    ) async -> (P?, PersistenceError?) {
        await withCheckedContinuation { (continuation: CheckedContinuation<(P?, PersistenceError?), Never>) in
            service.retrieve(key) { (object: P?, error) in
                continuation.resume(returning: (object, error))
            }
        }
    }
    
    /// Generic helper for operations that return an array and error
    private func awaitRetrieveMultiple<P: PersistenceObject>(
        _ service: AsyncPersistenceService,
        _ keys: [String]
    ) async -> ([P], PersistenceError?) {
        await withCheckedContinuation { (continuation: CheckedContinuation<([P], PersistenceError?), Never>) in
            service.retrieve(keys) { (objects: [P], error) in
                continuation.resume(returning: (objects, error))
            }
        }
    }
    
    /// Generic helper for retrieving all objects of a type
    private func awaitRetrieveAll<P: PersistenceObject>(
        _ service: AsyncPersistenceService,
        objectOfType: P.Type
    ) async -> ([P], PersistenceError?) {
        await withCheckedContinuation { (continuation: CheckedContinuation<([P], PersistenceError?), Never>) in
            service.retrieve(objectOfType: objectOfType) { (objects: [P], error) in
                continuation.resume(returning: (objects, error))
            }
        }
    }
    
    /// Generic helper for remove operations
    private func awaitRemove<P: PersistenceObject>(
        _ service: AsyncPersistenceService,
        _ object: P
    ) async -> PersistenceError? {
        await withCheckedContinuation { (continuation: CheckedContinuation<PersistenceError?, Never>) in
            service.remove(object) { error in
                continuation.resume(returning: error)
            }
        }
    }
    
    // MARK: - Store Tests
    
    @Test("Store and retrieve object using async callbacks")
    func asyncCallbackStoreAndRetrieve() async {
        let service = AsyncPersistenceService()
        let testId = "async-test-\(UUID().uuidString)"
        let model = try! TestModel(id: testId, name: "Alice")
        
        let storeError = await awaitStore(service, model)
        #expect(storeError == nil, "Store operation should succeed")
        
        let (object, retrieveError): (TestModel?, PersistenceError?) = await awaitRetrieve(service, testId)
        #expect(object?.id == testId, "Retrieved object ID should match")
        #expect(object?.name == "Alice", "Retrieved object name should match")
        #expect(retrieveError == nil, "Retrieve operation should succeed")
        
        // Cleanup
        _ = await awaitRemove(service, model)
    }
    
    // MARK: - Update Tests
    
    @Test("Update and retrieve object using async callbacks")
    func asyncCallbackUpdateAndRetrieve() async throws {
        let service = AsyncPersistenceService()
        let testId = "async-update-\(UUID().uuidString)"
        let model = try TestModel(id: testId, name: "Alice")
        
        // Store initial object
        let storeError = await awaitStore(service, model)
        #expect(storeError == nil, "Initial store should succeed")
        
        // Retrieve and verify initial state
        let (retrievedObject, retrieveError1): (TestModel?, PersistenceError?) = await awaitRetrieve(service, testId)
        #expect(retrieveError1 == nil, "Initial retrieve should succeed")
        #expect(retrievedObject?.name == "Alice", "Initial name should be Alice")
        
        // Ensure we have an object before proceeding
        guard var object = retrievedObject else {
            Issue.record("Failed to retrieve object after storing")
            return
        }
        
        // Update the object
        object.name = "Bob"
        
        let updateError = await awaitStore(service, object)
        #expect(updateError == nil, "Update store should succeed")
       
        // Verify the update
        let (updatedObject, retrieveError2): (TestModel?, PersistenceError?) = await awaitRetrieve(service, testId)
        #expect(retrieveError2 == nil, "Final retrieve should succeed")
        #expect(updatedObject?.id == testId, "ID should remain unchanged")
        #expect(updatedObject?.name == "Bob", "Name should be updated to Bob")
        
        // Cleanup - only if we have an object to remove
        if let finalObject = updatedObject {
            _ = await awaitRemove(service, finalObject)
        }
    }
    
    // MARK: - Retrieve Multiple Tests
    
    @Test("Store and retrieve multiple objects using async callbacks")
    func asyncCallbackStoreAndRetrieveMultipleObjects() async throws {
        let service = AsyncPersistenceService()
        let prefix = "async-multi-\(UUID().uuidString)"
        
        let model1 = try TestModel(id: "\(prefix)-1", name: "Alice")
        let model2 = try TestModel(id: "\(prefix)-2", name: "Mat")

        // Store both objects
        _ = await awaitStore(service, model1)
        _ = await awaitStore(service, model2)
        
        // Retrieve by specific keys
        let (objectsByKeys, keysError): ([TestModel], PersistenceError?) = 
            await awaitRetrieveMultiple(service, ["\(prefix)-1", "\(prefix)-2"])
        
        #expect(objectsByKeys.count == 2, "Should retrieve both objects by keys")
        #expect(keysError == nil, "Retrieve by keys should succeed")
        
        // Retrieve all of this type
        let (allObjects, allError): ([TestModel], PersistenceError?) = 
            await awaitRetrieveAll(service, objectOfType: TestModel.self)
        
        let ourObjects = allObjects.filter { $0.id.hasPrefix(prefix) }
        #expect(ourObjects.count == 2, "Should retrieve all our test objects")
        #expect(allError == nil, "Retrieve all should succeed")
        
        // Cleanup
        _ = await awaitRemove(service, model1)
        _ = await awaitRemove(service, model2)
    }
    
    // MARK: - Remove Tests
    
    @Test("Remove object using async callbacks")
    func asyncCallbackRemoveObject() async throws {
        let service = AsyncPersistenceService()
        let testId = "async-remove-\(UUID().uuidString)"
        let model = try TestModel(id: testId, name: "Bob")

        // Store the object
        _ = await awaitStore(service, model)
        
        // Remove the object
        let removeError = await awaitRemove(service, model)
        #expect(removeError == nil, "Remove operation should succeed")
        
        // Verify object is removed
        let (obj, _): (TestModel?, PersistenceError?) = await awaitRetrieve(service, testId)
        #expect(obj == nil, "Object should not exist after removal")
    }
    
    @Test("Remove non-existent object returns error")
    func asyncCallbackRemoveNonExistObject() async throws {
        let service = AsyncPersistenceService()
        let testId1 = "async-exist-\(UUID().uuidString)"
        let testId2 = "async-notexist-\(UUID().uuidString)"
        
        let model1 = try TestModel(id: testId1, name: "Bob")
        let model2 = try TestModel(id: testId2, name: "Ghost")

        // Store only model1
        _ = await awaitStore(service, model1)
        
        // Try to remove model2 (which doesn't exist)
        let removeError = await awaitRemove(service, model2)
        #expect(removeError != nil, "Should return error when removing non-existent object")
        
        // Cleanup
        _ = await awaitRemove(service, model1)
    }
    
    // MARK: - Concurrency Tests
    
    @Test("Concurrent async operations are thread-safe")
    func concurrentAsyncOperations() async throws {
        let service = AsyncPersistenceService()
        let prefix = "async-concurrent-\(UUID().uuidString)"
        
        // Store multiple objects concurrently
        await withTaskGroup(of: Void.self) { group in
            for i in 0..<10 {
                group.addTask {
                    let model = try! TestModel(id: "\(prefix)-\(i)", name: "Object \(i)")
                    _ = await self.awaitStore(service, model)
                }
            }
        }
        
        // Small delay to ensure all writes complete
        try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
        
        // Verify all objects were stored
        let (allObjects, _): ([TestModel], PersistenceError?) = 
            await awaitRetrieveAll(service, objectOfType: TestModel.self)
        
        let concurrentObjects = allObjects.filter { $0.id.hasPrefix(prefix) }
        #expect(concurrentObjects.count == 10, "All concurrent operations should succeed")
        
        // Cleanup
        await withTaskGroup(of: Void.self) { group in
            for i in 0..<10 {
                group.addTask {
                    let model = try! TestModel(id: "\(prefix)-\(i)", name: "Object \(i)")
                    _ = await self.awaitRemove(service, model)
                }
            }
        }
    }
    
    // MARK: - Error Handling Tests
    
    @Test("Retrieve non-existent object returns nil without error")
    func retrieveNonExistent() async throws {
        let service = AsyncPersistenceService()
        let testId = "async-fake-\(UUID().uuidString)"
        
        let (object, error): (TestModel?, PersistenceError?) = await awaitRetrieve(service, testId)
        
        #expect(object == nil, "Non-existent object should return nil")
        #expect(error == nil, "Should not return error for non-existent object")
    }
    
    @Test("Retrieve with empty keys returns empty array")
    func retrieveEmptyKeys() async throws {
        let service = AsyncPersistenceService()
        
        let (objects, error): ([TestModel], PersistenceError?) = await awaitRetrieveMultiple(service, [])
        
        #expect(objects.isEmpty, "Empty keys should return empty array")
        #expect(error == nil, "Should not return error for empty keys")
    }
    
    // MARK: - Performance Tests
    
    @Test("Bulk store operations complete successfully")
    func bulkStoreOperations() async throws {
        let service = AsyncPersistenceService()
        let prefix = "async-bulk-\(UUID().uuidString)"
        let count = 50
        
        for i in 0..<count {
            let model = try TestModel(id: "\(prefix)-\(i)", name: "Bulk \(i)")
            _ = await awaitStore(service, model)
        }
        
        let (allObjects, _): ([TestModel], PersistenceError?) = 
            await awaitRetrieveAll(service, objectOfType: TestModel.self)
        
        let bulkObjects = allObjects.filter { $0.id.hasPrefix(prefix) }
        #expect(bulkObjects.count == count, "All bulk objects should be stored")
        
        // Cleanup
        for i in 0..<count {
            let model = try TestModel(id: "\(prefix)-\(i)", name: "Bulk \(i)")
            _ = await awaitRemove(service, model)
        }
    }
}

