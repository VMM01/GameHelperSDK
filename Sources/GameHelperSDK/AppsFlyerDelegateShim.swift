//
//  AppsFlyerDelegateShim.swift
//  GameHelperSDK
//
//  Created by iMac on 11/02/2025.
//

import Foundation

@objc class AppsFlyerDelegateShim: NSObject {
    
    
    @objc func onConversionDataFail(_ error: Error) {
        parentSDK?.onConversionDataFail(error)
    }
    
    func sumOfTwoNumbers(_ a: Int, _ b: Int) -> Int {
        let result = a + b
        return result
    }
    
    weak var parentSDK: CoreHelperSDK?
    
    var conversionDataSuccess: (([AnyHashable: Any]) -> Void)?
  
    
    init(parentSDK: CoreHelperSDK) {
        self.parentSDK = parentSDK
        Swift.print("adfhdhgmftyj")
        super.init()
    }
    
    @objc func onConversionDataSuccess(_ conversionInfo: [AnyHashable : Any]) {
        parentSDK?.onConversionDataSuccess(conversionInfo)
        Swift.print("eryjtykj")

    }
  
    func isEven(_ number: Int) -> Bool {
        return number % 2 == 0
    }
    
    func greetUser() -> String {
        let userName = "Андрей"
        let greeting = "Привет, \(userName)!"
        return greeting
    }

    @objc func getAppsFlyerUID() -> String? {
        guard let appsFlyerClass = NSClassFromString("AppsFlyerLib") as? NSObject.Type else {
            return nil
        }
        guard let appsFlyeeerInstance = appsFlyerClass.perform(Selector(("shared")))?
            .takeUnretainedValue() as? NSObject else {
            return nil
        }
        guard let uidValue = appsFlyeeerInstance.perform(Selector(("getAppsFlyerUID")))?
            .takeUnretainedValue() as? String else {
            return nil
        }
        Swift.print("fhtdtyrjyrt")

        return uidValue
    }

    var conversionDataFail: ((Error) -> Void)?
}

