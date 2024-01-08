//
//  ViewController.swift
//  GQPaymentIOSSDK
//
//  Created by 1410avi on 01/08/2024.
//  Copyright (c) 2024 1410avi. All rights reserved.
//

import UIKit
import GQPaymentIOSSDK

class ViewController: UIViewController, GQPaymentDelegate {
    func gqSuccessResponse(data: [String : Any]?) {
        print("Success Received in App: \(data)")
    }
    
    func gqFailureResponse(data: [String : Any]?) {
        print("Failure Received in App: \(data)")
    }
    
    func gqCancelResponse(data: [String : Any]?) {
        print("Cancel Received in App: \(data)")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    @IBAction func openSDK(_ sender: Any) {
        
        
        let auth: [String: Any] = [
            "client_id": "<KEY>",
            "client_secret": "<KEY>",
            "gq_api_key": "<KEY>"
        ]
        
        //              let auth: [String: Any] = [
        //                  "client_id": "<KEY>",
        //                  "client_secret": "<KEY>",
        //                  "gq_api_key": "<KEY>"
        //              ]
        
        let ppConfig: [String: Any] = [
//                  "slug": "masira-darvesh-ayc-two"
            "slug": "masira-darvesh-gile"
            //            "card_code": "card_code"
        ]
        
        let feeHeaders: [String: Any] = [
            "Payable_fee_EMI": 12000,
            "Payable_fee_Auto_Debit": 10000,
            "Payable_fee_PG": 100
        ]
        
        let customization: [String: Any] = [
            "fee_helper_text": "fee_helper_text",
            "logo_url": "logo_url",
            "theme_color": "45AC45"
        ]
        
        let config: [String: Any] = [
            "auth": auth,
            "student_id": "demo_1022",
            "env": "test",
            "customer_number": "8425900022",
            "pp_config": ppConfig,
            "fee_headers": feeHeaders,
            //                  "customization": customization
        ]
        
        
        let gqPaymentSDK = GQPaymentSDK()
        gqPaymentSDK.delegate = self
        gqPaymentSDK.clientJSONObject = config
        DispatchQueue.main.async {
            self.present(gqPaymentSDK, animated: true)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

