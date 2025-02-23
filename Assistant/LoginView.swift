//
//  LoginView.swift
//  Assistant
//
//  Created by Divyansh Bhardwaj on 21/02/25.
//

import SwiftUI
import KindeSDK

struct LoginView: View {
    @State private var presentAlert = false
    @State private var alertMessage = ""
    private let hintEmail = "test@test.com"

    private let logger: Logger?
    private let onLoggedIn: () -> Void
    private let auth: Auth = KindeSDKAPI.auth

    init(logger: Logger?, onLoggedIn: @escaping () -> Void) {
        self.logger = logger
        self.onLoggedIn = onLoggedIn
    }
    
    @State private var botOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            Image(.BG)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack{
                Spacer(minLength: 139)
                
                Image(.bot)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 338, height: 306)
                    .shadow(color: .black.opacity(0.3), radius: 10, x: -10, y: 10)
                    .offset(y: botOffset)
                    .padding(.bottom, 45)
                    .padding(.leading, 36)
                    .animation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: botOffset)
                    .onAppear {
                        botOffset = -10
                    }
                
                
                Text("The Most Trusted And Fast Chatbot Ever")
                    .font(.title)
                    .bold()
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)

                Text("Buddy is the most trusted and fast chatbot ever made on the internet.")
                    .font(.body)
                    .foregroundStyle(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                    .padding(.bottom, 32)
                
                HStack(spacing: 16) {
                    Button(action: login) {
                        RoundedRectangle(cornerRadius: 14)
                            .frame(width: 163, height: 56)
                            .foregroundStyle(.black)
                            .overlay(Text("Sign In")
                                .font(.headline)
                                .foregroundStyle(.white))
                    }

                    Button(action: register) {
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.black, lineWidth: 2) // Black border
                            .background(Color.white) // White background
                            .cornerRadius(14)
                            .frame(width: 163, height: 56)
                            .overlay(Text("Sign Up")
                                .font(.headline)
                                .foregroundStyle(.black))
                    }
                }
                .padding(.horizontal, 24)

                Spacer(minLength: 72)
            }
        }
    }

    func signIn() {
        print("Sign In tapped")
    }
}

//#Preview {
//    LoginView()
//}

extension LoginView {
    func register() {
        auth.enablePrivateAuthSession(true)
        auth.register(loginHint: hintEmail) { result in
            switch result {
            case let .failure(error):
                if !auth.isUserCancellationErrorCode(error) {
                    alertMessage = "Registration failed: \(error.localizedDescription)"
                    self.logger?.error(message: alertMessage)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        presentAlert = true
                    }
                }
            case .success:
                self.onLoggedIn()
            }
        }
    }
    
    func login() {
        auth.enablePrivateAuthSession(true)
        auth.login(loginHint: hintEmail) { result in
            switch result {
            case let .failure(error):
                if !auth.isUserCancellationErrorCode(error) {
                    alertMessage = "Login failed: \(error.localizedDescription)"
                    self.logger?.error(message: alertMessage)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        presentAlert = true
                    }
                }
            case .success:
                self.onLoggedIn()
            }
        }
    }
}
