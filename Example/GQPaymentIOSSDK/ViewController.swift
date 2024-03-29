//
//  ViewController.swift
//  GQPaymentIOSSDK
//
//  Created by 1410avi on 01/08/2024.
//  Copyright (c) 2024 1410avi. All rights reserved.
//

import UIKit
import GQPaymentIOSSDK
import SwiftUI

class ViewController: UIViewController, GQPaymentDelegate {
    func gqSuccessResponse(data: [String : Any]?) {
        callBackMessage += convertDictionaryToJson(dictionary: data!)!
        DispatchQueue.main.async {
            self.callback.isHidden = false
        }
        print("Success callback received with data: \(data)")
    }
    
    func gqFailureResponse(data: [String : Any]?) {
        print("Failure callback received with data: \(data)")
        callBackMessage += convertDictionaryToJson(dictionary: data!)!
        DispatchQueue.main.async {
            self.callback.isHidden = false
        }
//        self.dismiss(animated: true, completion: nil)
    }
    
    func gqCancelResponse(data: [String : Any]?) {
        print("Cancel callback received with data: \(data)")
//        openAlert(title: "Cancel", message: "\(data)")
        callBackMessage += convertDictionaryToJson(dictionary: data!)!
        DispatchQueue.main.async {
            self.callback.isHidden = false
        }
    }
    
    
    @IBOutlet weak var txtClientId: UITextField!
    @IBOutlet weak var txtClientSecretKey: UITextField!
    @IBOutlet weak var txtGqApiKey: UITextField!
    @IBOutlet weak var txtEnvironment: UITextField!
    @IBOutlet weak var txtStudentID: UITextField!
    @IBOutlet weak var txtCustomerNumber: UITextField!
    @IBOutlet weak var txtPPConfig: UITextField!
    @IBOutlet weak var txtFeeHeader: UITextField!
    @IBOutlet weak var txtCustomization: UITextField!
    @IBOutlet weak var txtOptionalData: UITextField!
    
    @IBOutlet weak var callback: UIButton!
    var clientID: String?
    var clientSecretKey: String?
    var gqApiKey: String?
    var environment: String?
    var studentID: String?
    var customerNumber: String?
    var ppConfig: String?
    var feeHeader: String?
    var customization: String?
    var optionalObj: String?
    var callBackMessage: String = ""
    
    var config: [String: Any] = [:]
    var auth: [String: Any] = [:]
    var ppConfigObj: [String: Any] = [:]
    var feeHeqaderObj: [String: Any] = [:]
    var customizationObj: [String: Any] = [:]
    var optionalDataObj: [String: Any] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        callback.isHidden = true
    }
    
    @IBAction func btnOpenSdk(_ sender: UIButton) {
        callBackMessage = ""
        if !callback.isHidden {
            callback.isHidden.toggle()
        }
        clientID = txtClientId.text
        clientSecretKey = txtClientSecretKey.text
        gqApiKey = txtGqApiKey.text
        
        environment = txtEnvironment.text
        studentID = txtStudentID.text
        customerNumber = txtCustomerNumber.text
        
        ppConfig = txtPPConfig.text
        feeHeader = txtFeeHeader.text
        customization = txtCustomization.text
        optionalObj = txtOptionalData.text
        
        openSDK()
        
    }
    func openSDK(){
        auth = [:]
        config = [:]
        
        if let unwrapClientId = clientID, !unwrapClientId.isEmpty,
           let unwrapSecretKey = clientSecretKey, !unwrapSecretKey.isEmpty,
           let unwrapGqApi = gqApiKey, !unwrapGqApi.isEmpty{
            print("true")
            auth = [
                "client_id": unwrapClientId,
                "client_secret_key": unwrapSecretKey,
                "gq_api_key": unwrapGqApi
            ]
            
            config["auth"] = auth
        } else {
            print("false")
        }
        
        
        config["student_id"] = studentID
        config["env"] = environment
        
        if let unwrapCustomerNumber = customerNumber, !unwrapCustomerNumber.isEmpty{
            config["customer_number"] = unwrapCustomerNumber
        }
        
        if let unwrapCustomization = customization, !unwrapCustomization.isEmpty{
            config["customization"] = converString(dataString: unwrapCustomization)
        }
        
        if let unwrapPPConifg = ppConfig, !unwrapPPConifg.isEmpty{
            print("ppConfigConvert: \(converString(dataString: ppConfig!))")
            config["pp_config"] = converString(dataString: unwrapPPConifg)
        }
        
        if let unwrapFeeHeader = feeHeader, !unwrapFeeHeader.isEmpty{
            config["fee_headers"] = converString(dataString: unwrapFeeHeader)
        }
        
        print("Config Object: \(config)")
        
        let gqPaymentSDK = GQPaymentSDK()
        
        gqPaymentSDK.modalPresentationStyle = .overFullScreen
        gqPaymentSDK.modalTransitionStyle = .crossDissolve
        
        gqPaymentSDK.delegate = self
        gqPaymentSDK.clientJSONObject = config
        if let wrapOption = optionalObj, !wrapOption.isEmpty{
            gqPaymentSDK.prefillJSONObject = converString(dataString: wrapOption)
        }
        DispatchQueue.main.async {
            self.present(gqPaymentSDK, animated: true)
        }
        
    }
    @IBAction func callback(_ sender: UIButton) {
//        if var wrapCallBack = callBackMessage, !wrapCallBack.isEmpty{
            openAlert(title: "CallBack Listner", message: callBackMessage)
//        }
    }
    @IBAction func btnPrefill(_ sender: UIButton) {
        txtClientId.text = "GQ-0d2ed24e-cc1f-400b-a4e3-7208c88b99b5"
        txtClientSecretKey.text = "a96dd7ea-7d4a-4772-92c3-ac481713be4a"
        txtGqApiKey.text = "b59bf799-2a82-4298-b901-09c512ea4aaa"
        
//        txtClientId.text = "GQ-70e832de-41f2-4937-b84c-86e3006fbb0d"
//        txtClientSecretKey.text = "803acef6-d8cf-40f5-9ff7-c539cd8e91ef"
//        txtGqApiKey.text = "9bc8d0f0-718e-4e51-b3cb-54e97aa228f0"
        
        txtEnvironment.text = "test"
//        txtEnvironment.text = "stage"
        
        txtStudentID.text = "sample_99"
        txtCustomerNumber.text = "9025968023"
        
        txtPPConfig.text = "{\"slug\": \"masira-darvesh-gile\"}"
        txtFeeHeader.text = "{\"Payable_fee_EMI\":12000,\"Payable_fee_Auto_Debit\":10000,\"Payable_fee_PG\": 100}"
    }
    
    func converString(dataString: String) -> [String:Any] {
        
        // Convert the JSON string to Data
        if let jsonData = dataString.data(using: .utf8) {
            do {
                // Deserialize the JSON data into a dictionary
                if let dataObj = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                    // Now, dataObj is a dictionary of type [String: Any]
                    print(dataObj)
                    return dataObj
                } else {
                    return [:]
                    print("Failed to cast JSON object to [String: Any]")
                }
            } catch {
                return [:]
                print("Error deserializing JSON: \(error)")
            }
        } else {
            return [:]
            print("Failed to convert JSON string to data")
        }
    }
    
    func openAlert(title: String, message: String){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            
            self?.present(alert, animated: true, completion: nil)
        }
    }
    
    func convertDictionaryToJson(dictionary: [String: Any]) -> String? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            } else {
                print("Error converting JSON data to string.")
                return nil
            }
        } catch {
            print("Error converting dictionary to JSON: \(error.localizedDescription)")
            return nil
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

