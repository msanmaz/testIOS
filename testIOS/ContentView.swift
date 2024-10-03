//
//  ContentView.swift
//  testIOS
//
//  Created by Mert Osanmaz on 03/10/2024.

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState // Observe AppState

    var body: some View {
        Group {
            if appState.isLoggedIn {
                MainTabView() // Show MainTabView after login
            } else {
                LoginView(viewModel: LoginViewModel()) // Inject the LoginViewModel
            }
        }
    }
}



#Preview {
    ContentView()
}
