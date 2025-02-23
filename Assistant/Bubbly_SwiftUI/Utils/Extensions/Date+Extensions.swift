//
//  Created by Alex.M on 08.07.2022.
//

import Foundation

extension Date {
    func randomTime() -> Date {
        var hour = Int.random(min: 0, max: 23)
        var minute = Int.random(min: 0, max: 59)
        var second = Int.random(min: 0, max: 59)

        let current = Calendar.current.dateComponents([.hour, .minute, .second], from: Date())
        let curHour = current.hour ?? 23
        let curMinute = current.minute ?? 59
        let curSecond = current.second ?? 59

        if hour > curHour {
            hour = curHour
        } else if hour == curHour, minute > curMinute {
            minute = curMinute
        } else if hour == curHour, minute == curMinute, second > curSecond {
            second = curSecond
        }

        var components = Calendar.current.dateComponents([.year, .month, .day], from: self)
        components.hour = hour
        components.minute = minute
        components.second = second
        return Calendar.current.date(from: components)!
    }
}

class DateFormatting {
    static var agoFormatter = RelativeDateTimeFormatter()
}

extension Date {
    // 1 hour ago, 2 days ago...
    func formatAgo() -> String {
        let result = DateFormatting.agoFormatter.localizedString(for: self, relativeTo: Date())
        if result.contains("second") {
            return "Just now"
        }
        return result
    }
}

extension DateFormatter {
    static let timeFormatter = {
        let formatter = DateFormatter()

        formatter.dateStyle = .none
        formatter.timeStyle = .short

        return formatter
    }()

    static let relativeDateFormatter = {
        let relativeDateFormatter = DateFormatter()
        relativeDateFormatter.timeStyle = .none
        relativeDateFormatter.dateStyle = .full
        relativeDateFormatter.locale = Locale(identifier: "en_US")
        relativeDateFormatter.doesRelativeDateFormatting = true

        return relativeDateFormatter
    }()

    static func timeString(_ seconds: Int) -> String {
        let hour = Int(seconds) / 3600
        let minute = Int(seconds) / 60 % 60
        let second = Int(seconds) % 60

        if hour > 0 {
            return String(format: "%02i:%02i:%02i", hour, minute, second)
        }
        return String(format: "%02i:%02i", minute, second)
    }
}


//import UIKit
//extension UIFont {
//    static func customFont(ofSize size: CGFloat, weight: UIFont.Weight) -> UIFont {
//        switch weight {
//        case .bold:
//            return UIFont(name: "CustomFont-Bold", size: size) ?? UIFont.systemFont(ofSize: size, weight: weight)
//        case .semibold:
//            return UIFont(name: "CustomFont-SemiBold", size: size) ?? UIFont.systemFont(ofSize: size, weight: weight)
//        case .medium:
//            return UIFont(name: "CustomFont-Medium", size: size) ?? UIFont.systemFont(ofSize: size, weight: weight)
//        case .regular:
//            return UIFont(name: "CustomFont-Regular", size: size) ?? UIFont.systemFont(ofSize: size, weight: weight)
//        default:
//            return UIFont(name: "CustomFont-Regular", size: size) ?? UIFont.systemFont(ofSize: size, weight: weight)
//        }
//    }
//}
