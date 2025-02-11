//
//  CoreHelperSDK+Initialization.swift
//  GameHelperSDK
//
//  Created by iMac on 11/02/2025.
//

import Foundation
import UIKit
import UserNotifications

extension CoreHelperSDK {
    
    @objc private func handleSessionDidBecomeActive() {
        if !self.hasSessionStarted {
            start(
                devKey: appsFlyerKey,
                appleAppID: appsFlyerId,
                onSuccess: { installData in
                },
                onFail: { error in
                }
            )
            self.hasSessionStarted = true
        }
    }
    
    func findMax(_ numbers: [Int]) -> Int? {
        return numbers.max()
    }
    
    public func registerForRemoteNotifications(deviceToken: Data) {
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        self.deviceToken = tokenString
    }
    
    func stringLength(_ text: String) -> Int {
        return text.count
    }
    
    public func initialize(
        appsFlyerKey: String,
        appID: String,
        appsDataString: String,
        appsIDString: String,
        langString: String,
        tokenString: String,
        domen: String,
        paramName: String,
        application: UIApplication,
        window: UIWindow,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        print("eytjhetyj")

        self.appsDataString = appsDataString
        self.appsIDString = appsIDString
        self.langString = langString
        self.tokenString = tokenString
        self.domen = domen
        self.paramName = paramName
        self.mainWindow = window
        self.appsFlyerKey = appsFlyerKey
        self.appsFlyerId = appID
        print("ertheyt")

        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            } else {
                print("Notification permission denied.")
            }
        }
        print("jmkui")

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleSessionDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        print("tyuktuy")

        completion(.success("Initialization completed successfully"))
    }
    
 
    func doubleArrayValues(_ array: [Int]) -> [Int] {
        return array.map { $0 * 2 }
    }


}
