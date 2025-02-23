 //
 //  PollingManager.swift
 //  Bobble
 //
 //  Created by Divyansh Bhardwaj on 22/11/24.
 //  Copyright © 2024 Touchtalent. All rights reserved.
 //

import Foundation
import UIKit

 enum ContentType: String, Codable {
    case animatedSticker = "animatedSticker"
    case movieGIF = "movieGif"
    case sticker = "sticker"
    case genericCard = "genericCard"
    case generic = "generic"
    case gif = "gif"
    case emojiSticker = "emojiSticker"
    case story = "story"
    case meme = "meme"
    case text = "text"
    case unknown = "unknown"
    case dotsAnimationView = "dotsAnimationView"
 }

 enum Role: String, Codable {
    case user, assistant
 }


 class PollingManager {
    private let sharedDefaults = UserDefaults(suiteName: "com.divyansh.tititle")
    private var pollingTimer: Timer?
    let cacheDirectory: URL = {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("MediaCache")
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }()
     
     
     
     func startPolling(
         interval: TimeInterval,
         onDataReceived: @escaping (DraftMessage) -> Void
     ) {
         Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
             guard let self = self else { return }
             
             let workItem = DispatchWorkItem {
                 guard let sharedDefaults = self.sharedDefaults else { return }
                 guard let encodedData = sharedDefaults.data(forKey: "sd_key") else { return }
                 
                 do {
                     let decoder = JSONDecoder()
                     let mediaData = try decoder.decode(MediaData.self, from: encodedData)
//                     print("Media Data Checkpoint: \(mediaData)")
                     
//                     let draftMessage = DraftMessage(
//                         id: UUID().uuidString,
//                         content: mediaData.message ?? "",
//                         mediaURL: mediaData.contentURL,
//                         mediaType: mediaData.contentType.toMediaType()
//                     )
                     
                     let bubblyReply = self.convertToDraftMessage(from: mediaData)
                    
//                     let media: Media? = {
//                         if let contentURL = mediaData.contentURL {
//                             return Media(source: CustomImageModel(url: contentURL, type: mediaData.contentType.toMediaType()))
//                         }
//                         return nil
//                     }()
//
//                     let draftMessage = DraftMessage(
//                         id: UUID().uuidString,
//                         text: mediaData.message ?? "",
//                         medias: media,
//                         createdAt: Date()
//                     )
                     onDataReceived(bubblyReply)
                     sharedDefaults.removeObject(forKey: "sd_key")
                     
                 } catch {
                     print("Failed to decode media data: \(error)")
                 }
             }
             
             DispatchQueue.main.async(execute: workItem)
         }
     }
     
//    func startPolling(interval: TimeInterval, onDataReceived: @escaping (String, String?, ContentType, Role, String?, NSAttributedString?,CGSize?) -> Void) {
//        pollingTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
//            DispatchQueue.main.async {
//                guard let sharedDefaults = self?.sharedDefaults else { return }
//               
//                guard let encodedData = sharedDefaults.data(forKey: "sd_key") else { return }
//               
//                do {
//                    let decoder = JSONDecoder()
//                    let mediaData = try decoder.decode(MediaData.self, from: encodedData)
//                    print(mediaData)
//                   
//                    switch mediaData.contentType {
//                    case .sticker, .genericCard:
//                        if let contentURL = mediaData.contentURL {
//                            onDataReceived(contentURL.absoluteString, mediaData.message, mediaData.contentType, mediaData.role, nil,nil, mediaData.size)
//                        }
//                       
//                    case .animatedSticker, .emojiSticker, .movieGIF, .gif, .meme, .generic, .story:
//                        if let contentURL = mediaData.contentURL {
//                            if (contentURL.absoluteString.contains(".jpeg")) ||
//                                (contentURL.absoluteString.contains(".png")) ||
//                                (contentURL.absoluteString.contains(".jpg")) {
//                                onDataReceived(contentURL.absoluteString, nil, mediaData.contentType, mediaData.role, nil,nil, mediaData.size)
//                            } else {
//                                if(mediaData.isFromSuggestionPills != nil){
//                                    let fileManager = FileManager.default
//                                    let userDefaults = UserDefaults.standard
//                                    let videoIdentifier = mediaData.isFromSuggestionPills! + KeyboardEnableViewController().getCurrentLocaleNew()
//                                    if let appGroupContainer = fileManager.containerURL(forSecurityApplicationGroupIdentifier: APPGROUPID) {
//                                        let videoDirectoryURL = appGroupContainer.appendingPathComponent("Videos")
//                                        let videoFileName =  "\(videoIdentifier).mov"
//                                        let videoURL = videoDirectoryURL.appendingPathComponent(videoFileName)
////                                        let otf_keyword = VideoPlayerViewController().fetchDefaultText(identifier: mediaData.isFromSuggestionPills!)
//                                        if(FileManager.default.fileExists(atPath: videoURL.path)) {
//                                            print("Video is already present: \(videoFileName)")
////                                            DispatchQueue.main.async{
////                                                onDataReceived(videoURL.absoluteString, mediaData.message, .story, mediaData.role, otf_keyword, InMessageTableViewCell().retrieveAttributedStringFromUserDefaults(), nil)
//                                               
////                                                self?.sendEventForSendingEvent(success : "Success", identifier : otf_keyword)
////                                            }
//                                        }
//                                        else {
//                                            DispatchQueue.main.async{
////                                                self?.sendEventForSendingEvent(success : "Fail", identifier : otf_keyword)
//                                                print("Video for \(videoIdentifier) has not been downloaded yet.")
//                                            }
//                                        }
//                                    }
//                                   
//                                }
//                                else {
//                                    onDataReceived(contentURL.absoluteString, mediaData.message, mediaData.contentType, mediaData.role, nil,nil, mediaData.size)
//                                }
//                            }
//                        }
//                    case .unknown:
//                        print("Unknown content type received.")
//                       
//                    case .text:
//                        break
//                    case .dotsAnimationView:
//                        break
//                    }
//                   
//                    sharedDefaults.removeObject(forKey: "sd_key")
//                   
//                } catch {
//                    print("Failed to decode media data: \(error)")
//                }
//            }
//        }
//    }


    func checkIfThisIsSuggestionPill() -> Bool{
        return true
    }


    func downloadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error downloading image: \(error)")
                completion(nil)
                return
            }
           
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    completion(image)
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
        task.resume()
    }
   
    func stopPolling() {
        pollingTimer?.invalidate()
        pollingTimer = nil
    }
     
     func convertToDraftMessage(from mediaData: MediaData) -> DraftMessage {
         let draftMessageID = UUID().uuidString
         let mediaID = UUID().uuidString

         guard let contentURL = mediaData.contentURL else {
             return DraftMessage(
                 id: draftMessageID,
                 text: mediaData.message ?? "",
                 createdAt: Date()
             )
         }

         let image: MockImage? = (mediaData.contentType == .sticker || mediaData.contentType == .emojiSticker || mediaData.contentType == .animatedSticker || mediaData.contentType == .meme) ? MockImage(
             id: mediaID,
             thumbnail: contentURL,
             full: contentURL
         ) : nil

         let video: MockVideo? = (mediaData.contentType == .movieGIF || mediaData.contentType == .story || mediaData.contentType == .gif) ? MockVideo(
             id: mediaID,
             thumbnail: contentURL,
             full: contentURL
         ) : nil

         let draftMessage = DraftMessage(
             id: draftMessageID,
             text: mediaData.message ?? "",
             createdAt: Date(),
             image: image,
             video: video
         )

         return draftMessage
     }
 }


struct MediaData: Codable {
    var contentURL: URL?
    var message: String?
    var contentType: ContentType
    var role: Role
    var isFromSuggestionPills: String? = nil
    var size : CGSize? = nil
}


extension ContentType {
    func toMediaType() -> MediaType? {
        switch self {
        case .sticker, .animatedSticker, .emojiSticker, .gif, .movieGIF, .meme, .generic, .story:
            return .image
        case .text:
            return nil
        default:
            return nil
        }
    }
}


struct CustomImageModel: MediaModelProtocol {
    var duration: CGFloat?
    var mediaType: MediaType? // This can now be set during initialization.
    var url: URL

    init(url: URL, type: MediaType? = .image) {
        self.url = url
        self.mediaType = type
    }

    func getURL() async -> URL? {
        return url
    }

    func getThumbnailURL() async -> URL? {
        return url
    }

    func getData() async throws -> Data? {
        return try? Data(contentsOf: url)
    }

    func getThumbnailData() async -> Data? {
        return try? Data(contentsOf: url)
    }
}
