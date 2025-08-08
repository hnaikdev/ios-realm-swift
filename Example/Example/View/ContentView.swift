//
//  ContentView.swift
//  Example
//
//  Created by Hiral Naik on 8/7/25.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var viewModel: UserViewModel
    @State var showProgress: Bool = false
    
    init(viewModel: UserViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                if showProgress {
                    ProgressView().controlSize(.large)
                } else {
                    if viewModel.apiError != nil {
                        Text("Error loading users")
                    } else {
                        List(viewModel.users) { user in
                            VStack(alignment: .leading) {
                                Text(user.name)
                                Text(user.company)
                                Text(user.email)
                                Text(user.phone)
                                Button {
                                    Task {
                                        await viewModel.removeUser(for: user.id)
                                    }
                                } label: {
                                    Text("Remove User!")
                                }

                            }
                        }
                    }
                }
                
                Spacer()
                
                Button {
                    Task {
                        showProgress = true
                        await viewModel.fetchUsers()
                        showProgress = false
                    }
                } label: {
                    Text("Refresh Users Data")
                }
                
            }
        }
    }
}
