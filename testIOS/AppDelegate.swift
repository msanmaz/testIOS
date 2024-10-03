//
//  testIOSApp.swift
//  testIOS
//
//  Created by Mert Osanmaz on 03/10/2024.
//

import SwiftUI

@main
struct testIOSApp: App {
    @StateObject var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState) // Inject AppState globally
        }
    }
}






class AppState: ObservableObject {
    @Published var isLoggedIn: Bool = false
}
