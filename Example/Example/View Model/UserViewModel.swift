//
//  UserViewModel.swift
//  Example
//
//  Created by Hiral Naik on 8/8/25.
//

import Foundation

struct UserElement: Identifiable, Hashable {
    let id: Int
    let name: String
    let company: String
    let email: String
    let phone: String
    let avatar: String
    var selected: Bool = false
}

class UserViewModel: ObservableObject {
    
    let service: APIServiceProtocol
    @Published var users: [UserElement] = []
    @Published var apiError: APIServiceError? = nil
    
    init(service: APIServiceProtocol) {
        self.service = service
    }
    
    func fetchUsers() async {
        do {
            let result = try await service.fetchData()
            let elements = result.map({ generateViewModel(user: $0) })
            await MainActor.run {
                users = elements
            }
        } catch let error as APIServiceError {
            await MainActor.run {
                apiError = error
            }
        } catch  {
            await MainActor.run {
                users = []
            }
        }
    }
    
    private func generateViewModel(user: User) -> UserElement {
        return UserElement(id: user.id!, name: user.name ?? "", company: user.company ?? "", email: user.email ?? "", phone: user.phone ?? "", avatar: user.photo ?? "")
    }
    
    @MainActor
    func removeUser(for id: Int) async {
        do {
            try await service.delete(for: id)
            if let index = users.firstIndex(where: { $0.id == id }) {
                users.remove(at: index)
            }
        } catch {
            apiError = error as? APIServiceError
        }
    }
}
