//
//  LoginView.swift
//  testIOS
//
//  Created by Mert Osanmaz on 03/10/2024.
//

import SwiftUI

struct LoginView: View {
    @StateObject var viewModel: LoginViewModel
    @EnvironmentObject var appState: AppState // Access the appState

    var body: some View {
        VStack {
            TextField("Email", text: $viewModel.email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
            
            SecureField("Password", text: $viewModel.password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            if viewModel.isCreatingAccount {
                TextField("Username", text: $viewModel.username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
            }
            
            Button(viewModel.isCreatingAccount ? "Create Account" : "Login") {
                viewModel.isCreatingAccount ? viewModel.createAccount() : viewModel.login()
            }
            
            Button(viewModel.isCreatingAccount ? "Back to Login" : "Create Account") {
                viewModel.isCreatingAccount.toggle()
            }
        }
        .onReceive(viewModel.$isLoggedIn) { isLoggedIn in
                    if isLoggedIn {
                        appState.isLoggedIn = true // Update the global state when logged in
                    }
                }
        .padding()
        .alert(isPresented: $viewModel.showAlert) {
            Alert(title: Text(viewModel.isCreatingAccount ? "Create Account" : "Login"), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK")))
        }
    }
}
