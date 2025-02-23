//
//  ContentView.swift
//  May AI
//
//  Created by Divyansh Bhardwaj on 15/02/25.
//

import SwiftUI
import KindeSDK

struct ContentView: View {
    @State private var isAuthenticated: Bool
    @State private var user: UserProfile?
    @State private var presentAlert = false
    @State private var alertMessage = ""

    private let logger: Logger?

    init() {
        self.logger = Logger()
        
        // Configure Kinde authentication service
        KindeSDKAPI.configure(self.logger ?? DefaultLogger())
        
        _isAuthenticated = State(initialValue: KindeSDKAPI.auth.isAuthorized())
    }

    var body: some View {
        Group {
            if isAuthenticated {
                HomeView()
            } else {
                LoginView(logger: self.logger, onLoggedIn: onLoggedIn)
                    .transition(.opacity)
                    .animation(.easeInOut, value: isAuthenticated)
            }
        }
        .onAppear {
            // Ensure authentication status is updated
//            Task{
//                await logout()
//            }
            isAuthenticated = KindeSDKAPI.auth.isAuthorized()
            
            if isAuthenticated, user == nil {
                getUserProfile()
            }
        }
        .alert(isPresented: $presentAlert) {
            Alert(
                title: Text("Error"),
                message: Text(alertMessage)
            )
        }
    }
}

#Preview {
    ContentView()
}

extension ContentView {
    func onLoggedIn() {
        isAuthenticated = true
        getUserProfile()
    }

    func onLoggedOut() {
        isAuthenticated = false
        user = nil
    }

    private func getUserProfile() {
        Task {
            isAuthenticated = await asyncGetUserProfile()
        }
    }

    private func asyncGetUserProfile() async -> Bool {
        do {
            let userProfile = try await OAuthAPI.getUser()
            self.user = userProfile
            let userName = "\(userProfile.givenName ?? "") \(userProfile.familyName ?? "")"
            self.logger?.info(message: "Got profile for user \(userName)")
            return true
        } catch {
            alertMessage = "Failed to get user profile: \(error.localizedDescription)"
            self.logger?.error(message: alertMessage)
            presentAlert = true
            return false
        }
    }

    func logout() async {
        do {
            try await KindeSDKAPI.auth.logout()
            isAuthenticated = false
            print("Successfully logged out")
        } catch {
            print("Logout failed: \(error.localizedDescription)")
        }
    }
}
