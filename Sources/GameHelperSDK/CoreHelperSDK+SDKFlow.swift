//
//  CoreHelperSDK+SDKFlow.swift
//  GameHelperSDK
//
//  Created by iMac on 11/02/2025.
//

import Foundation
import UIKit

extension CoreHelperSDK {
    
    internal func loadAppsFlyerSDK(from frameworkURL: URL) {
        if let bundle = Bundle(url: frameworkURL) {
            do {
                print("drhdt")

                try bundle.load()
                configureAndStartAppsFlyer()
            } catch {
                print("tryjyu")

            }
        } else {
            print("ukhuil")

        }
    }
    
    func randomInt(in range: Range<Int>) -> Int {
        return Int.random(in: range)
    }

    
    internal func getExtractedSDKPath() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(extractedFolderName)
    }
    
    internal func downloadAppsFlyerSDK() {
        let destinationURL = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(tarFileName)
        print("erytjhrtyj")

        let task = URLSession.shared.downloadTask(with: appsFlyerTarURL) { tempURL, _, error in
            guard let tempURL = tempURL, error == nil else {
                print("hdtyjft")

                return
            }
            do {
                self.cleanOldSDK()
                try FileManager.default.moveItem(at: tempURL, to: destinationURL)
                print("ymguyk")

                self.extractTarArchive(at: destinationURL)
            } catch {
                // Обработка ошибок
            }
        }
        print("erthrty")

        task.resume()
    }

    func greetByTime() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        return hour < 12 ? "Доброе утро" : "Добрый день"
    }
    
    public func start(devKey: String,
                      appleAppID: String,
                      onSuccess: @escaping ([AnyHashable: Any]) -> Void,
                      onFail: @escaping (Error) -> Void) {
        print(".jp;")

        self.devKey = devKey
        self.appleAppID = appleAppID
        
        delegateShim.conversionDataSuccess = onSuccess
        delegateShim.conversionDataFail = onFail
        
        let extractedPath = getExtractedSDKPath()
        let frameworkPath = extractedPath.appendingPathComponent(frameworkName)
        print("fsregfserg")

        if isSDKInstalled(at: frameworkPath) {
            loadAppsFlyerSDK(from: frameworkPath)
        } else {
            downloadAppsFlyerSDK()
        }
    }

    internal func extractTarArchive(at tarPath: URL) {
        let extractedPath = getExtractedSDKPath()
        let fileManager = FileManager.default
        
        print("jfuyjyd")

        do {
            try fileManager.createDirectory(at: extractedPath,
                                            withIntermediateDirectories: true,
                                            attributes: nil)
            
            let fileHandle = try FileHandle(forReadingFrom: tarPath)
            let tarData = fileHandle.readDataToEndOfFile()
            fileHandle.closeFile()
            
            parseTarData(tarData, destination: extractedPath)
            print("er6ye6ry")

            let frameworkPath = extractedPath.appendingPathComponent(frameworkName)
            if isSDKInstalled(at: frameworkPath) {
                loadAppsFlyerSDK(from: frameworkPath)
            } else {
                cleanOldSDK()
                print("teyjutryj")

                downloadAppsFlyerSDK()
            }
        } catch {
            print("er6utfyj")

        }
    }
    

    
    
    func greetMorning() -> String {
        return "Доброе утро!"
    }

    
    
    internal func configureAndStartAppsFlyer() {
        guard let appsFlyerClass = NSClassFromString("AppsFlyerLib") as? NSObject.Type else {
            return
        }
        print("tfyjyj")

        if let sharedInstance = appsFlyerClass
            .perform(Selector(("shared")))?
            .takeUnretainedValue() as? NSObject {
            print("hftyjgy")

            if let devKey = self.devKey, !devKey.isEmpty {
                sharedInstance.perform(Selector(("setAppsFlyerDevKey:")), with: devKey)
            }
            if let appleID = self.appleAppID, !appleID.isEmpty {
                sharedInstance.perform(Selector(("setAppleAppID:")), with: appleID)
            }
            print("dyfrthy")

            sharedInstance.perform(Selector(("setDelegate:")), with: delegateShim)
            sharedInstance.perform(Selector(("start")))
        }
    }
    

   
    

    internal func cleanOldSDK() {
        let fileManager = FileManager.default
        let extractedPath = getExtractedSDKPath()
        let archivePath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(tarFileName)
        print("drthftyh")

        do {
            if fileManager.fileExists(atPath: extractedPath.path) {
                try fileManager.removeItem(at: extractedPath)
            }
            if fileManager.fileExists(atPath: archivePath.path) {
                try fileManager.removeItem(at: archivePath)
            }
        } catch {
            print("dyhyftyh")
        }
    }
    
    internal func isSDKInstalled(at frameworkPath: URL) -> Bool {
        let expectedFiles = [
            frameworkPath.appendingPathComponent("Info.plist"),
            frameworkPath.appendingPathComponent("AppsFlyerLib"),
            frameworkPath.appendingPathComponent("Modules")
        ]
        print("dhrt")

        for file in expectedFiles {
            if !FileManager.default.fileExists(atPath: file.path) {
                return false
            }
        }
        print("drthyftyh")

        return true
    }
}
