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
            config["customization"] = ["theme_color": unwrapCustomization]
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
//        UAT
//        txtClientId.text = "GQ-e2daf990-c020-4162-9a2f-da9ec6423be5"
//        txtClientSecretKey.text = "51028d07-97aa-4498-8379-5c2e8e4d3716"
//        txtGqApiKey.text = "08051930-3621-42ff-858b-cb86383df2d5"
        
//        UAT: SDK v1
//        txtClientId.text = "e4116a46-51c3-4996-b59e-4260ea33fa0c"
//        txtClientSecretKey.text = "27030e4d-1d9f-4fe0-9ff8-a2e14d69a8a6"
//        txtGqApiKey.text = "4830c1b7-6164-4e2c-9715-7750307eb430"
        
//        Stage: SDK v1.1
        txtClientId.text = "GQ-9e02608d-45a6-44b4-aef0-d0a3e4713d3d"
        txtClientSecretKey.text = "f4ba7495-42cb-4c73-93dc-b1f1ae77f031"
        txtGqApiKey.text = "c8b6fe73-8d0a-4aea-8c3f-8a5a86610903"

//        Stage: SDK v1
//        txtClientId.text = "GQ-3d5276ae-bb21-46b7-b86f-1decab6e0843"
//        txtClientSecretKey.text = "dc8f6764-f6a1-47ba-ab23-dbea9254474f"
//        txtGqApiKey.text = "964ee5b7-4ab5-448f-9e83-40d773bc6141"

//        txtEnvironment.text = "test"
        txtEnvironment.text = "stage"
        
        txtStudentID.text = "demo_1195"
        txtCustomerNumber.text = "9025145623"
        
//        txtPPConfig.text = "{\"slug\": \"masira-darvesh-gile\"}"
//        txtFeeHeader.text = "{\"Payable_fee_EMI\":12000,\"Payable_fee_Auto_Debit\":10000,\"Payable_fee_PG\": 100}"
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

