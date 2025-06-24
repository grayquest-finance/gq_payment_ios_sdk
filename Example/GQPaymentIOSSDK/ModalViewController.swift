//
//  FirstViewController.swift
//  GQPaymentIOSSDK
//
//  Created by Velentine Miranda on 15/05/25.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit
import GQPaymentIOSSDK

class ModalViewController: UIViewController, GQPaymentDelegate {
    
    @IBOutlet weak var openSDKButton: UIButton!
    @IBOutlet weak var openNewView: UIButton!
    private var callbackText: String = ""
    
    
    var config: [String: Any] = [:]
    var optionalDataObj: [String: Any] = [:]

    var token: String?
    var env: String?
    
    @IBAction func clickedOpenNewView(_ sender: UIButton) {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "ModalViewController") as! ModalViewController
            controller.config = self.config
            controller.optionalDataObj = self.optionalDataObj
            controller.token = self.token
            controller.env = self.env
            self.present(controller, animated: true)
        }
    }
    
    @IBAction func clickedOpenSDKButton(_ sender: UIButton) {
        openSDK()
    }
    
    @IBAction func clickedOpenSDKWithTokenButton(_ sender: UIButton) {
        openSDK(with: token, env: env ?? "")
    }
    
    @MainActor private func openSDK() {
        let gqPaymentSDK = GQPaymentSDK()
        
        gqPaymentSDK.modalPresentationStyle = .overFullScreen
        gqPaymentSDK.modalTransitionStyle = .crossDissolve
        
        gqPaymentSDK.delegate = self
        gqPaymentSDK.clientJSONObject = config
        gqPaymentSDK.prefillJSONObject = optionalDataObj
        
        self.present(gqPaymentSDK, animated: true)
    }
    
    @MainActor private func openSDK(with token: String?, env: String) {
        let gqPaymentSDK = GQPaymentSDK()
        
        gqPaymentSDK.modalPresentationStyle = .overFullScreen
        gqPaymentSDK.modalTransitionStyle = .crossDissolve
        
        gqPaymentSDK.delegate = self
        gqPaymentSDK.authToken = token
        gqPaymentSDK.env = env
        
        self.present(gqPaymentSDK, animated: true)
    }
    
    @IBAction func clickedClosedSDK(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.dismiss(animated: true)
        }
    }
    
    @IBAction func clickedDisplayCallbackButton(_ sender: UIButton) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "Callback", message: self.callbackText, preferredStyle: .alert)
            let closeAction = UIAlertAction(title: "Close", style: .default)
            alertController.addAction(closeAction)
            self.present(alertController, animated: true)
        }
    }
    
    func gqSuccessResponse(data: [String : Any]?) {
        print("Success")
        if let data {
            callbackText += "\(data)"
        }
    }
    
    func gqFailureResponse(data: [String : Any]?) {
        print("Failure")
        if let data {
            callbackText += "\(data)"
        }
    }
    
    func gqCancelResponse(data: [String : Any]?) {
        print("Cancel")
        if let data {
            callbackText += "\(data)"
        }
    }
    
}
