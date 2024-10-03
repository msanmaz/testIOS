//
//  LoginView.swift
//  testIOS
//
//  Created by Mert Osanmaz on 03/10/2024.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel: LoginViewModel
    @EnvironmentObject private var authService: AuthenticationService
    
    init() {
        _viewModel = StateObject(wrappedValue: LoginViewModel())
    }
    
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
                viewModel.isCreatingAccount ? viewModel.createAccount(authService: authService) : viewModel.login(authService: authService)
            }
            
            Button(viewModel.isCreatingAccount ? "Back to Login" : "Create Account") {
                viewModel.isCreatingAccount.toggle()
            }
        }
        .padding()
        .alert(isPresented: $viewModel.showAlert) {
            Alert(title: Text(viewModel.isCreatingAccount ? "Create Account" : "Login"), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK")))
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AuthenticationService())
    }
}
