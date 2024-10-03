//
//  testIOSApp.swift
//  testIOS
//
//  Created by Mert Osanmaz on 03/10/2024.
//

import SwiftUI

@main
struct testIOSApp: App {
    @StateObject private var authService = AuthenticationService()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authService)
        }
    }
}

