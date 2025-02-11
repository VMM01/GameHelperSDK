//
//  CoreSDK+Notifications.swift
//  GameHelperSDK
//
//  Created by iMac on 11/02/2025.
//

import Foundation
import UIKit

extension CoreHelperSDK {
    
    func repeatText(_ text: String, count: Int) -> String {
        return String(repeating: text, count: count)
    }
    
    internal func sendNotificationError(name: String) {
        print("dfghdfj")

        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: NSNotification.Name(name),
                object: nil,
                userInfo: ["notificationMessage": "Error occurred"]
            )
        }
        print("sftjdytj")

    }
    
    func isPalindrome(_ text: String) -> Bool {
        return text.lowercased() == String(text.lowercased().reversed())
    }
    internal func sendNotification(name: String, message: String) {
        print("fgjukfukjf")

        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: NSNotification.Name(name),
                object: nil,
                userInfo: ["notificationMessage": message]
            )
        }
        print("dtyjdytj")

    }
    
    func filterPositive(_ numbers: [Int]) -> [Int] {
        return numbers.filter { $0 > 0 }
    }
}
