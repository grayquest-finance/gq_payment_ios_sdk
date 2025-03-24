//
//  SceneDelegate.swift
//  GQPaymentIOSSDK
//
//  Created by Valentine on 15/01/25.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        let rootViewController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(identifier: "ViewController") as! ViewController

        window.rootViewController = rootViewController
        self.window = window
        window.makeKeyAndVisible()
    }
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb, let url = userActivity.webpageURL else { return }

        // Handle the Universal Link
        print("Received Universal Link: \(url.absoluteString)")
        // Add custom handling for the URL
    }
}

