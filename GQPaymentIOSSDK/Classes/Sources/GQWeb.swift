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
    
    private let gqCallbackURL: String = "svc-dp.graydev.tech"
    
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
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
}

extension GQWeb: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.hideLoader()
        if let urlString = webView.url?.absoluteString, urlString.contains(gqCallbackURL) {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
}
