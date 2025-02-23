//
//  CustomLoginView.swift
//  Assistant
//
//  Created by Divyansh Bhardwaj on 21/02/25.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift // Import for the GoogleSignInButton
import UIKit

struct CustomLoginView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var isAuthenticated: Bool
    @State private var presentAlert = false
    @State private var alertMessage = ""
    @State private var signInConfig = GIDConfiguration.init(clientID: "392008644172-7hqos7ulbicja0b336pc15s46gqu8sa8.apps.googleusercontent.com")
    private let logger: Logger?
    
    init(isAuthenticated: Binding<Bool>, logger: Logger? = nil) {
        self._isAuthenticated = isAuthenticated
        self.logger = logger
    }
    
    var body: some View {
        VStack {
            Text("Login with:")
                .font(.title)
                .padding()
            
            GoogleSignInButton(action: googleLogin)
                .padding(.bottom, 10)
            
            Button(action: {
                // Initiate Facebook Login
                //                facebookLogin()
            }) {
                Text("Facebook")
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .padding(.bottom, 10)
            
            Button(action: {
                // Initiate Apple Login
                appleLogin()
            }) {
                Text("Apple")
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.black)
                    .cornerRadius(8)
            }
            
        }
        .alert(isPresented: $presentAlert) {
            Alert(
                title: Text("Error"),
                message: Text(alertMessage)
            )
        }
    }
    
    // MARK: - Login Functions
    
    func googleLogin() {
//        guard let rootViewController = UIApplication.shared.connectedScenes
//            .compactMap({ $0 as? UIWindowScene })
//            .first?.rootViewController else {
//            print("Failed to get rootViewController")
//            alertMessage = "Failed to get root view controller."
//            presentAlert = true
//            return
//        }
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let rootViewController = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController else {
                print("Failed to get rootViewController")
                return
            }
        
        let signInConfig = GIDConfiguration(clientID: "392008644172-7hqos7ulbicja0b336pc15s46gqu8sa8.apps.googleusercontent.com") // Replace with your actual client ID
        
        GIDSignIn.sharedInstance
            .signIn(
                withPresenting: rootViewController)
        { signInResult, error in
            if let error = error {
                print("Google Sign-In Failed: \(error.localizedDescription)")
                alertMessage = "Google Sign-In Failed: \(error.localizedDescription)"
                presentAlert = true
                return
            }
            
            guard let user = signInResult?.user,
                  let idToken = user.idToken?.tokenString else {
                print("Failed to retrieve Google user or ID token.")
                alertMessage = "Failed to retrieve Google user or ID token."
                presentAlert = true
                return
            }
            
            print("Google Login successful with token: \(idToken)")
            kindeAuthentication(token: idToken)
        }
    }
    //    func facebookLogin() {
    //        //Implement Facebook Login
    //        print("Facebook Login")
    //        // After successful login, call kindeAuthentication
    //    }
    
    func appleLogin() {
        //Implement Apple Login
        print("Apple Login")
        // After successful login, call kindeAuthentication
    }
    
    func kindeAuthentication(token: String) {
        //Send the token to your backend and get the Kinde token back
        Task {
            await sendTokenToBackend(token: token)
        }
    }
    
    func sendTokenToBackend(token: String) async {
        guard let url = URL(string: "YOUR_BACKEND_ENDPOINT") else {
            print("Invalid backend URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["social_token": token, "provider": "google"] // Adjust provider based on login type
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Backend request failed")
                return
            }
            
            let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            if let kindeToken = jsonResponse?["kinde_token"] as? String {
                // Store the Kinde token securely (Keychain)
                print("Kinde token received: \(kindeToken)")
                UserDefaults.standard.set(kindeToken, forKey: "kinde_token") // Replace with Keychain
                DispatchQueue.main.async {
                    self.isAuthenticated = true
                    self.presentationMode.wrappedValue.dismiss()
                }
                
            } else {
                print("Kinde token not found in response")
            }
        } catch {
            print("Error sending token to backend: \(error)")
        }
    }
}

