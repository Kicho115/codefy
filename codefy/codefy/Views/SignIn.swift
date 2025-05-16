//
//  SignIn.swift
//  codefy
//
//  Created by Oscar Angulo on 5/14/25.
//

import SwiftUI

struct SignIn: View {
    @StateObject private var viewModel = SignInViewModel()
    
    var body: some View {
            VStack(spacing: 20) {
                Text("Welcome to Codefy")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                TextField("Email", text: $viewModel.email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                
                SecureField("Password", text: $viewModel.password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                if !viewModel.errorMessage.isEmpty {
                    Text(viewModel.errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                Button(action: { viewModel.signIn() }) {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Sign In")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
                .disabled(viewModel.isLoading)
                
                NavigationLink("Don't have an account?", destination: SignUp())
                    .foregroundColor(.blue)
                    .padding(.top)
            }
            .padding()
            .navigationBarBackButtonHidden(true)
        }
    }


#Preview {
    SignIn()
}
