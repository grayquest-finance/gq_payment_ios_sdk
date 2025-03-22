//
//  GQWeb.swift
//  Pods
//
//  Created by Valentine on 14/01/25.
//

import UIKit
@preconcurrency import WebKit

@MainActor class GQWeb: GQViewController {
    
    private var webView: WKWebView!
    
    var loadURL: String?
    
    public override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.preferences.javaScriptCanOpenWindowsAutomatically = true
        
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        
        webView.navigationDelegate = self
        webView.scrollView.bounces = false
        
        if #available(iOS 16.4, *) {
            webView.isInspectable = true
        }
        
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showLoader()
        if let urlString = loadURL?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let myURL = URL(string: urlString) {
            let myRequest = URLRequest(url: myURL)
            webView.load(myRequest)
        } else {
            if let myURL = URL(string: "https://grayquest.com") {
                let myRequest = URLRequest(url: myURL)
                webView.load(myRequest)
            } else {
                print("GQPaymentSDK: Invalid URL Found")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
}

extension GQWeb: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
//    MARK: For Deep Linking UPI Payment Applications.
        if navigationAction.navigationType == .other, let url = navigationAction.request.url {
            let isDeepLink = Custom.validateDeepLinkingScheme(with: url)
            if isDeepLink {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                } else {
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Could not find UPI APP", message: "UPI App might not be installed", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(alert, animated: true)
                    }
                }
                decisionHandler(.cancel)
                return
            }
        }
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.hideLoader()
//    MARK: For Detecting Grayquest redirection URL.
        if let urlString = webView.url?.absoluteString, urlString.contains(Environment.shared.juspayCallbackURL) {
            DispatchQueue.main.async {
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
}
