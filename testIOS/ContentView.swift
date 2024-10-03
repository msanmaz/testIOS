//
//  ContentView.swift
//  testIOS
//
//  Created by Mert Osanmaz on 03/10/2024.

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var authService: AuthenticationService
    
    var body: some View {
        Group {
            if authService.isAuthenticated {
                MainTabView()
            } else {
                LoginView()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AuthenticationService())
    }
}
