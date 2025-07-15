# 🤖 Buddy — On-Device AI Chat App

**Buddy** is a fully native iOS chat application powered by **Meta's LLaMA 3** model, running entirely on-device using Apple’s **MLX** and **llmfarm**. It offers a private, real-time AI experience with no cloud dependency — everything runs locally on your iPhone.

---

## 🚀 Features

- 🔒 100% on-device inference with **Meta's LLaMA 3** using **MLX**
- 🧠 Integrated with **llmfarm** for lightweight local inference pipeline
- 🎨 Fully native **SwiftUI** chat interface
- 🖼️ Rich messaging support (text, images, media)
- ⚙️ Optimized for memory and performance using background threading
- 🔐 **Firebase Authentication** for secure login
- 📲 **Push Notifications** via Firebase Cloud Messaging

---

## 📱 Tech Stack

- **Swift & SwiftUI** – Native iOS development
- **MLX** – Apple’s machine learning framework for LLMs on Apple Silicon
- **llmfarm** – Local LLM inference pipeline
- **Firebase Auth & Messaging** – User login and push notifications
- **Xcode** – Development environment

---

## 📦 Installation Guide

> ⚠️ Note: This project requires a real iOS device (iPhone with A14 or higher recommended).  
> MLX & llmfarm are optimized for Apple Silicon (M1/M2/M3) systems.

### 1. Clone the Repository
```bash
git clone https://github.com/your-username/buddy-ai-chat-llama3-mlx.git
cd buddy-ai-chat-llama3-mlx
```
### 2. Install MLX and llmfarm Dependencies

#### Follow llmfarm’s official installation guide to:
   - Set up Python environment (recommend using conda or venv)
   - Download and convert LLaMA 3 weights
   - Run the local inference server

### 3. Open the Project in Xcode

#### open Buddy.xcodeproj

### 4. Configure Firebase
  - Go to Firebase Console
  - Create a new iOS project
  - Add your GoogleService-Info.plist to the project
  - Enable Firebase Auth and Cloud Messaging

### 5. Run the App
  - Connect a real iOS device
  - Set your signing team in Xcode settings
  - Run the app and interact with your locally running LLM!

## 📸 Screenshots

#### Coming soon…

## 📚 Resources
  - Meta LLaMA 3
  - MLX (Apple)
  - llmfarm
  - Firebase for iOS

## 🪪 License
#### This project is open-source under the MIT License.

## 🙌 Contributing
#### Pull requests are welcome! For major changes, please open an issue first to discuss what you’d like to change.
