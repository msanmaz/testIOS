//
//  MainTabView.swift
//  testIOS
//
//  Created by Mert Osanmaz on 03/10/2024.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var authService: AuthenticationService
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(AuthenticationService())
    }
}
