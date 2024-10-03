//
//  SettingsView.swift
//  testIOS
//
//  Created by Mert Osanmaz on 03/10/2024.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var authService: AuthenticationService
    @State private var showLogoutAlert = false
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Button("Logout") {
                        showLogoutAlert = true
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Settings")
            .alert(isPresented: $showLogoutAlert) {
                Alert(
                    title: Text("Logout"),
                    message: Text("Are you sure you want to logout?"),
                    primaryButton: .destructive(Text("Logout")) {
                        authService.logout()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(AuthenticationService())
    }
}
