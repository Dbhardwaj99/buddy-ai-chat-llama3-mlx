//
//  AssitantChatBotModel.swift
//  Bobble
//
//  Created by Arpit Dwivedi on 01/12/24.
//  Copyright © 2024 Touchtalent. All rights reserved.
//

import Foundation

struct AssitantChatBotModel: Codable {
    let chatbotAssitantSettings: ChatBotModel?
}

struct ChatBotModel: Codable {
    let name: String?
    let enableLLM: [String: Bool]
    let maxMessageQueueLength: Int?
    let greetingMessages: [String:[String]]
    let errorMessages: [String:[String]]
    let profilePictureURL: String?
    let greetingImageURL: String?
    let onboardingImageURL: String?
    let enableBannerImageURL: String?
    let onboardingImageDisplayDuration: Int?
    let onboardingTitleText: [String:String]
    let onboardingSubtitleText: [String:String]
    let appBarButtonSettings: AppBarButtonSettings?
    let suggestionClipSettings: [SuggestionClipSettings]?
    let farewellSettings: FarewellSettings?
    let messageFieldHintTexts: [String: [String]]
    
    
    var enableLLMLocalised: Bool {
        let tuple = returnKeyboardLanguage()
        
        if let locale = enableLLM[tuple.0] {
            return locale
        } else if let locale = enableLLM[tuple.1] {
            return locale
        } else {
            return enableLLM["default"] ?? false
        }
    }
    
    var greetingMessagesLocalised: [String] {
        let tuple = returnKeyboardLanguage()
        
        if let locale = greetingMessages[tuple.0] {
            return locale
        } else if let locale = greetingMessages[tuple.1] {
            return locale
        } else {
            return greetingMessages["default"] ?? []
        }
    }

    var messageFieldHintTextsLocalised: [String] {
        let tuple = returnKeyboardLanguage()
        
        if let locale = messageFieldHintTexts[tuple.0] {
            return locale
        } else if let locale = messageFieldHintTexts[tuple.1] {
            return locale
        } else {
            return messageFieldHintTexts["default"] ?? []
        }
    }
    
    var errorMessagessLocalised: [String] {
        let tuple = returnKeyboardLanguage()
        
        if let locale = errorMessages[tuple.0] {
            return locale
        } else if let locale = errorMessages[tuple.1] {
            return locale
        } else {
            return errorMessages["default"] ?? []
        }
    }
    
    var onboardingTitleTextLocalised: String {
        let tuple = returnKeyboardLanguage()
        
        if let locale = onboardingTitleText[tuple.0] {
            return locale
        } else if let locale = onboardingTitleText[tuple.1] {
            return locale
        } else {
            return onboardingTitleText["default"] ?? ""
        }
    }
    
    var onboardingSubtitleTextLocalised: String {
        let tuple = returnKeyboardLanguage()
        
        if let locale = onboardingSubtitleText[tuple.0] {
            return locale
        } else if let locale = onboardingSubtitleText[tuple.1] {
            return locale
        } else {
            return onboardingSubtitleText["default"] ?? ""
        }
    }
    
}

struct AppBarButtonSettings: Codable {
    let text: [String:String]
    let textColor: String?
    let backgroundColor: String?
    let strokeColor: String?
    let animationTimer: Int?
    
    
    var textLocalised: String {
        let tuple = returnKeyboardLanguage()
        
        if let locale = text[tuple.0] {
            return locale
        } else if let locale = text[tuple.1] {
            return locale
        } else {
            return text["default"] ?? ""
        }
    }
}

struct SuggestionClipSettings: Codable {
    let identifier: String?
    let iconUrl: ColorModeModel?
    let videoUrl: [String:String]
    let text: [String:String]
    let displayText: LocalisationColorModeModel
    let sharedText : [String : String]
    
    var videoUrlLocalised: String {
        let tuple = returnKeyboardLanguage()
        
        if let locale = videoUrl[tuple.0] {
            return locale
        } else if let locale = videoUrl[tuple.1] {
            return locale
        } else {
            return videoUrl["default"] ?? ""
        }
    }
    
    var textLocalised: String {
        let tuple = returnKeyboardLanguage()
        
        if let locale = text[tuple.0] {
            return locale
        } else if let locale = text[tuple.1] {
            return locale
        } else {
            return text["default"] ?? ""
        }
    }
    var sharedTextLocalised: String {
        let tuple = returnKeyboardLanguage()
        
        if let locale = sharedText[tuple.0] {
            return locale
        } else if let locale = sharedText[tuple.1] {
            return locale
        } else {
            return sharedText["default"] ?? ""
        }
    }
    
    
}

struct ColorModeModel: Codable {
    let lightTheme: String?
    let darkTheme: String?
}

struct LocalisationColorModeModel : Codable {
    let lightTheme: [String:String]
    let darkTheme: [String:String]
    
    
    var lightThemeLocalised: String {
        let tuple = returnKeyboardLanguage()
        
        if let locale = lightTheme[tuple.0] {
            return locale
        } else if let locale = lightTheme[tuple.1] {
            return locale
        } else {
            return lightTheme["default"] ?? ""
        }
    }
    
    var darkThemeLocalised: String {
        let tuple = returnKeyboardLanguage()
        
        if let locale = darkTheme[tuple.0] {
            return locale
        } else if let locale = darkTheme[tuple.1] {
            return locale
        } else {
            return darkTheme["default"] ?? ""
        }
    }
}

struct FarewellSettings: Codable {
    let title: [String:String]
    let subTitle1: [String:String]
    let subTitle2: [String:String]
    
    var titleLocalised: String {
        let tuple = returnKeyboardLanguage()
        
        if let locale = title[tuple.0] {
            return locale
        } else if let locale = title[tuple.1] {
            return locale
        } else {
            return title["default"] ?? ""
        }
    }
    
    var subTitle1Localised: String {
        let tuple = returnKeyboardLanguage()
        
        if let locale = subTitle1[tuple.0] {
            return locale
        } else if let locale = subTitle1[tuple.1] {
            return locale
        } else {
            return subTitle1["default"] ?? ""
        }
    }
    
    var subTitle2Localised: String {
        let tuple = returnKeyboardLanguage()
        
        if let locale = subTitle2[tuple.0] {
            return locale
        } else if let locale = subTitle2[tuple.1] {
            return locale
        } else {
            return subTitle2["default"] ?? ""
        }
    }
}

//MARK: Helper Function

func returnKeyboardLanguage() -> (String, String) {
    
    let preferredLanguages = Locale.preferredLanguages
    let primaryLanguage = preferredLanguages.first ?? "en-US"
    var languageCode = primaryLanguage.components(separatedBy: "-").first ?? "en"
//    if languageCode == "id" {
//        languageCode = "in"
//    }
    return (languageCode, primaryLanguage)
}

//struct MediaData: Codable {
//    var contentURL: URL?
//    var message: String?
//    var contentType: ContentType
//    var role: Role
//    var isFromSuggestionPills: String? = nil
//    var size : CGSize? = nil
//}


struct LLMResponseModel: Codable {
    let data: LLMTextModel?
}
struct LLMTextModel: Codable {
    let text: String?
}
