//
//  Logger.swift
//  May AI
//
//  Created by Divyansh Bhardwaj on 21/02/25.
//

import Foundation
import os.log
import KindeSDK

struct Logger: LoggerProtocol {
    func debug(message: String) {
        os_log("%s", type: .debug, message)
    }
    
    func info(message: String) {
        os_log("%s", type: .info, message)
    }
    
    func error(message: String) {
        os_log("%s", type: .error, message)
    }

    func fault(message: String) {
        os_log("%s", type: .fault, message)
    }
}

extension String {
    
    /// Navigation-safe access to a String character by 0-based index
    subscript(idx: Int) -> String? {
        return idx < self.count ? String(self[index(startIndex, offsetBy: idx)]) : nil
    }
}
