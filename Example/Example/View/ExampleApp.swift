//
//  ExampleApp.swift
//  Example
//
//  Created by Hiral Naik on 8/7/25.
//

import SwiftUI
import ios_realm_swift

@main
struct ExampleApp: App {
    var body: some Scene {
        WindowGroup {
            let persistentService = PersistenceService()
            let service = APIService(networkService: NetworkClient(), persistentService: persistentService)
            let viewModel = UserViewModel(service: service)
            ContentView(viewModel: viewModel)
        }
    }
}
