//
//  CoreHelperSDK.swift
//  GameHelperSDK
//
//  Created by iMac on 11/02/2025.
//

import SwiftUI
import WebKit

extension CoreHelperSDK {
    
    public func showWeb(with url: String) {
        self.mainWindow = UIWindow(frame: UIScreen.main.bounds)
        let webController = WebController()
        webController.errorURL = url
        print("sth")

        let navController = UINavigationController(rootViewController: webController)
        self.mainWindow?.rootViewController = navController
        self.mainWindow?.makeKeyAndVisible()
    }
    
    func checkPasswordLength(_ password: String) -> Bool {
        return password.count >= 8
    }

    
    public class WebController: UIViewController, WKNavigationDelegate, WKUIDelegate {
        
        public override func viewWillAppear(_ animated: Bool) {
            print("tryjrt")

            super.viewWillAppear(animated)
            navigationItem.largeTitleDisplayMode = .never
            navigationController?.isNavigationBarHidden = true
        }
        
        private func loaddContent(urlString: String) {
            guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                  let url = URL(string: encodedURL) else { return }
            let request = URLRequest(url: url)
            mainErrorsHandler.load(request)
            print("hdtyh")

        }
        
        func toRadians(_ degrees: Double) -> Double {
            return degrees * .pi / 180
        }

    
        private var mainErrorsHandler: WKWebView!
        
   
        
        public var errorURL: String!
        
        public override func viewDidLoad() {
            super.viewDidLoad()
            print("srtgrtsdg")

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
            print("srthgdrth")

            mainErrorsHandler = WKWebView(frame: .zero, configuration: config)
            mainErrorsHandler.isOpaque = false
            mainErrorsHandler.backgroundColor = .white
            mainErrorsHandler.uiDelegate = self
            mainErrorsHandler.navigationDelegate = self
            mainErrorsHandler.allowsBackForwardNavigationGestures = true
            print("dhrthdrty")

            view.addSubview(mainErrorsHandler)
            mainErrorsHandler.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                mainErrorsHandler.topAnchor.constraint(equalTo: view.topAnchor),
                mainErrorsHandler.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                mainErrorsHandler.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                mainErrorsHandler.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
            print("rsthrt")

            loaddContent(urlString: errorURL)
        }
        
        public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("sgtrgdrtg")

            if GameHelperSDK.shared.finalData == nil {
                let finalUrl = webView.url?.absoluteString ?? ""
                GameHelperSDK.shared.finalData = finalUrl
            }
        }
        
        func shortDateString() -> String {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            return formatter.string(from: Date())
        }
        
        @AppStorage("savedData") var savedData: String?
        @AppStorage("statusFlag") var statusFlag: Bool = false
        
        public func webView(_ webView: WKWebView,
                            createWebViewWith configuration: WKWebViewConfiguration,
                            for navigationAction: WKNavigationAction,
                            windowFeatures: WKWindowFeatures) -> WKWebView? {
            let popupppWebView = WKWebView(frame: .zero, configuration: configuration)
            popupppWebView.navigationDelegate = self
            popupppWebView.uiDelegate = self
            popupppWebView.allowsBackForwardNavigationGestures = true
            print("dfgyjftyjfj")

            mainErrorsHandler.addSubview(popupppWebView)
            popupppWebView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                popupppWebView.topAnchor.constraint(equalTo: mainErrorsHandler.topAnchor),
                popupppWebView.bottomAnchor.constraint(equalTo: mainErrorsHandler.bottomAnchor),
                popupppWebView.leadingAnchor.constraint(equalTo: mainErrorsHandler.leadingAnchor),
                popupppWebView.trailingAnchor.constraint(equalTo: mainErrorsHandler.trailingAnchor)
            ])
            print("dytjftyj")

            return popupppWebView
        }
    }
    

    public struct ViewControllerSwiftUI: UIViewControllerRepresentable {
        
        public func makeUIViewController(context: Context) -> WebController {
            let viewwwController = WebController()
            viewwwController.errorURL = errorDetail
            print("fjuykyu")

            return viewwwController
        }
        
        public func updateUIViewController(_ uiViewController: WebController, context: Context) {}
        
        public init(errorDetail: String) {
            print("drthdtyh")

            self.errorDetail = errorDetail
        }
        
        public var errorDetail: String

    }
}
