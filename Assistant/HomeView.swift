//
//  HomeView.swift
//  Assistant
//
//  Created by Divyansh Bhardwaj on 22/02/25.
//

import SwiftUI
import Pow

struct HomeView: View {
    @State private var showChat: Bool = false
    @State private var showImage: Bool = true
    @State private var wiggleButton: Bool = true
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                // Safe area padding
                Color.clear.frame(height: geometry.safeAreaInsets.top)
                
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        Image(.c1)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 48, height: 48)
                            .padding(.leading, 24)
                        
                        VStack(alignment: .leading, spacing: 1) {
                            Text("Hey Divyansh")
                                .bold()
                                .font(.title)
                                .foregroundStyle(.white)
                            Text("Good Evening")
                                .font(.caption)
                                .foregroundStyle(.gray)
                        }
                        .padding(.leading, 8)
                        
                        Spacer()
                        
                        Image(.profile)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 35, height: 35)
                            .clipShape(Circle()) // Ensuring profile image looks better
                            .padding(.trailing, 24)
                    }
                    .frame(height: 60)
                    
                        // Two Rectangles Row
                        HStack(spacing: 20) {
                            // Premium Card
                            ZStack {
                                if showImage {
                                    Image(.premium)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 204, height: 166)
                                        .cornerRadius(15)
                                        .transition(.movingParts.glare)
                                }else{
                                    Image(.premium)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 204, height: 166)
                                        .cornerRadius(15)
                                }
                                
                                VStack(alignment: .leading, spacing: 16) {
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text("Buddy Premium")
                                            .font(.title2)
                                            .fontWeight(.heavy)
                                            .foregroundStyle(.white)
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.7)
                                        
                                        Text("Unlock premium features")
                                            .font(.title3)
                                            .foregroundStyle(.gray)
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.7)
                                    }
                                    .padding(.leading, 12)
                                    
                                    Button(action: {
                                        // Upgrade action
                                    }) {
                                        RoundedRectangle(cornerRadius: 10)
                                            .frame(width: 77, height: 34)
                                            .foregroundStyle(Color(hex: "#EDB01B"))
                                            .overlay(
                                                Text("Upgrade")
                                                    .font(.caption)
                                                    .bold()
                                                    .foregroundStyle(.white)
                                            )
                                    }
                                    .padding(.leading, 12)
                                }
                            }
                            .frame(width: 204, height: 166)
                            .cornerRadius(15)
                            
                            
                            // New Chat Card
                            Rectangle()
                                .foregroundStyle(Color(hex: "5D5FEF"))
                                .frame(maxWidth: .infinity, minHeight: 166)
                                .cornerRadius(15)
                                .onTapGesture {
                                    showChat = true
                                }
                                .overlay(
                                    VStack(spacing: 10) {
                                        Image(.r4)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 82, height: 82)
                                        
                                        RoundedRectangle(cornerRadius: 30)
                                            .frame(width: 110, height: 44)
                                            .foregroundStyle(.white)
                                            .overlay(
                                                HStack {
                                                    Text("New Chat")
                                                        .font(.caption)
                                                        .bold()
                                                        .foregroundStyle(.black)
                                                        .lineLimit(2)
                                                        .frame(width: 52, height: 44)
                                                    
                                                    Image(.dropDown)
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 26, height: 26)
                                                }
                                                    .padding(.horizontal, 9)
                                            )
                                            .conditionalEffect(
                                                .repeat(
                                                    .wiggle(
                                                        rate: .fast
                                                    ),
                                                    every: 5
                                                ),
                                                condition: wiggleButton
                                            )
                                    }
                                        .padding(.vertical, 16)
                                )
                        }
                        .padding(.horizontal, 16)
                        
                        // Large Rectangles (Content Area)
                    VStack(spacing: 12) {
                        Rectangle()
                            .foregroundStyle(.clear)
                            .frame(maxWidth: .infinity, minHeight: 200)
                            .padding(.horizontal, 16)
                            .overlay(
                                VStack {
                                    HStack {
                                        Text("Quick Prompts")
                                            .font(.title2)
                                            .bold()
                                        Spacer()
                                    }
                                    .padding(.bottom, 16)
                                    
                                    ScrollView(.vertical, showsIndicators: false) {
                                        LazyVStack(spacing: 12) { // Ensures proper stacking
                                            ForEach(0..<2, id: \.self) { _ in
                                                quickPrompt
                                            }
                                        }
                                    }
                                    .frame(height: 140) // Keeps prompts inside the rectangle
                                }
                                .padding(.horizontal, 16)
                            )
                        
                        Rectangle()
                            .foregroundStyle(.clear)
                            .frame(maxWidth: .infinity, minHeight: 300)
                            .padding(.horizontal, 16)
                            .overlay(
                                VStack {
                                    HStack {
                                        Text("Past Conversations")
                                            .font(.title2)
                                            .bold()
                                        Spacer()
                                    }
                                    .padding(.bottom, 16)
                                    
                                    ScrollView(.vertical, showsIndicators: false) {
                                        LazyVStack(spacing: 12) { // Ensures proper stacking
                                            ForEach(0..<4, id: \.self) { _ in
                                                pastConversations
                                            }
                                        }
                                    }
                                    .frame(height: 280) // Keeps prompts inside the rectangle
                                }
                                .padding(.horizontal, 16)
                            )
                    }
//                    .padding(.horizontal, 20)
                }
                .frame(maxWidth: .infinity)
            }
            .edgesIgnoringSafeArea(.top)
            .onAppear(perform: {
                toggleImageEvery15Seconds()
            })
            .fullScreenCover(isPresented: $showChat) {
                BubblyView(title: "Hello", showChat: $showChat)
            }
        }
    }
    
    var quickPrompt: some View {
        HStack(spacing: 16) {
            Image(.r1)
                .resizable()
                .scaledToFit()
                .frame(width: 52, height: 52)

            RoundedRectangle(cornerRadius: 14)
                .foregroundStyle(.white)
                .frame(minWidth: 268, maxHeight: 52)
                .overlay(content: {
                    HStack{
                        Text("Suggest something to cook")
                            .foregroundStyle(.black)
                            .font(.title2)
                            .bold()
                            .lineLimit(1)
                            .multilineTextAlignment(.leading)
                            .minimumScaleFactor(0.7)
                        
                        Image(.dropDown)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 26, height: 26)
                            .rotationEffect(Angle.degrees(-90))
                    }
                    .padding(.horizontal, 8)
                })
        }
    }
    
    var pastConversations: some View {
        RoundedRectangle(cornerRadius: 16)
            .foregroundStyle(Color(hex: "#F5F8FC"))
            .frame(minWidth: 268, minHeight: 84)
            .overlay(
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .frame(width: 71, height: 71)
                            .foregroundStyle(.white)
                        Image(.r3)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                    }
                    .padding(.leading, 16)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Chat Title")
                            .font(.title) // Adjusted size for better readability
                            .fontWeight(.heavy)
                            .foregroundStyle(.black)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)

                        Text("Chat 1 Description which can be a great addition...")
                            .font(.caption)
                            .foregroundStyle(.gray)
                            .lineLimit(2)
                            .minimumScaleFactor(0.8)
                    }
                    .frame(minWidth: 219)
                    .padding(.bottom, 18)
                    .padding(.leading, 4)
                    
                    VStack{
                        Image(.dot)
                            .padding(.leading, 4)
                            .padding(.top, 12)
                        
                        Spacer()
                    }
                    
                }
            )
    }
    
    func toggleImageEvery15Seconds() {
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                showImage.toggle()
            }
        }
    }

}

#Preview {
    HomeView()
}
