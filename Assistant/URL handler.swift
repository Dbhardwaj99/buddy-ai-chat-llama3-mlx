//
//  URL handler.swift
//  May AI
//
//  Created by Divyansh Bhardwaj on 15/02/25.
//

import Foundation
import SwiftUI

class URLHandler: ObservableObject {
    @Published var isSuccess: Bool = false
    @Published var isFailure: Bool = false
    
    func handle(url: URL) {
        print("Received URL: \(url.absoluteString)")
        // Match exactly the URLs you set as callbacks:
        if url.absoluteString == "com.imdb.May-AI://oauth2-success" {
            isSuccess = true
            isFailure = false
        } else if url.absoluteString == "com.imdb.May-AI://oauth2-failure" {
            isSuccess = false
            isFailure = true
        }
    }
}
