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
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var txtClientId: UITextField!
    @IBOutlet weak var txtClientSecretKey: UITextField!
    @IBOutlet weak var txtGqApiKey: UITextField!
    @IBOutlet weak var txtEnvironment: UITextField!
    @IBOutlet weak var txtStudentID: UITextField!
    @IBOutlet weak var txtCustomerNumber: UITextField!
    @IBOutlet weak var txtPPConfig: UITextField!
    @IBOutlet weak var txtFeeHeader: UITextField!
    @IBOutlet weak var txtReferenceID: UITextField!
    @IBOutlet weak var txtCustomization: UITextField!
    @IBOutlet weak var txtOptionalData: UITextField!
    @IBOutlet weak var txtEMIPlanID: UITextField!
    @IBOutlet weak var txtUDFDetails: UITextField!
    
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
    var referenceID: String?
    var emiPlanID: String?
    var udfDetails: String?
    
    var config: [String: Any] = [:]
    var auth: [String: Any] = [:]
    var ppConfigObj: [String: Any] = [:]
    var feeHeqaderObj: [String: Any] = [:]
    var customizationObj: [String: Any] = [:]
    var optionalDataObj: [String: Any] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addKeyboardObserver()
        handleTapGesture()
        callback.isHidden = true
    }
    
    private func addKeyboardObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
        
        referenceID = txtReferenceID.text
        emiPlanID = txtEMIPlanID.text
        udfDetails = txtUDFDetails.text
        
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
        
        if let referenceID, !referenceID.isEmpty {
            config["reference_id"] = referenceID
        }
        
        if let emiPlanID, !emiPlanID.isEmpty {
            config["emi_plan_id"] = emiPlanID
        }
        
        if let udfDetails, !udfDetails.isEmpty {
            config["udf_details"] = converString(dataString: udfDetails)
        }
        
        if let unwrapCustomerNumber = customerNumber, !unwrapCustomerNumber.isEmpty {
            config["customer_number"] = unwrapCustomerNumber
        }
        
        if let customization, !customization.isEmpty {
            config["customization"] = ["theme_color": customization]
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
//        UAT: Pranit Test
        txtClientId.text = "GQ-d9167506-30ac-4a0d-bb61-8e487a596c43"
        txtClientSecretKey.text = "4a937d7a-5b41-445c-94ae-4289efff2237"
        txtGqApiKey.text = "513476f6-dfa9-4bc4-9ae3-8da925a1207d"
        
//        UAT: With Fee Headers
//        txtClientId.text = "GQ-2c854cb5-8c84-4cfd-a73a-4748703b0b1a"
//        txtClientSecretKey.text = "c1fd2b30-3fda-419b-b7ac-87f5a188b793"
//        txtGqApiKey.text = "6d139a48-1c33-461d-a3f0-c2e32837ec5e"
        
//        UAT: SDK v1
//        txtClientId.text = "GQ-d9167506-30ac-4a0d-bb61-8e487a596c43"
//        txtClientSecretKey.text = "4a937d7a-5b41-445c-94ae-4289efff2237"
//        txtGqApiKey.text = "513476f6-dfa9-4bc4-9ae3-8da925a1207d"
        
//        Stage: SDK v1.1
//        txtClientId.text = "GQ-9e02608d-45a6-44b4-aef0-d0a3e4713d3d"
//        txtClientSecretKey.text = "f4ba7495-42cb-4c73-93dc-b1f1ae77f031"
//        txtGqApiKey.text = "c8b6fe73-8d0a-4aea-8c3f-8a5a86610903"

//        Stage: SDK v1
//        txtClientId.text = "GQ-3d5276ae-bb21-46b7-b86f-1decab6e0843"
//        txtClientSecretKey.text = "dc8f6764-f6a1-47ba-ab23-dbea9254474f"
//        txtGqApiKey.text = "964ee5b7-4ab5-448f-9e83-40d773bc6141"

        txtEnvironment.text = "test"
//        txtEnvironment.text = "stage"
        
        txtStudentID.text = "demo_1234"
        txtCustomerNumber.text = "9090909090"
        
//        txtPPConfig.text = ""
//        txtFeeHeader.text = "{\"Payable_fee_EMI\": 120000.00, \"Payable_fee_Auto_Debit\": 20, \"Payable_fee_PG\": 150}"
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
                    print("Failed to cast JSON object to [String: Any]")
                    return [:]
                }
            } catch {
                print("Error deserializing JSON: \(error)")
                return [:]
            }
        } else {
            print("Failed to convert JSON string to data")
            return [:]
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
    
    private func handleTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension ViewController {
    
    @objc func keyboardWillShow(notification: Notification){
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        DispatchQueue.main.async {
            let keyboardScreenEndFrame = keyboardValue.cgRectValue
            let keyboardViewEndFrame = self.view.convert(keyboardScreenEndFrame, from: self.view.window)

            let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - self.view.safeAreaInsets.bottom, right: 0)

            self.scrollView.contentInset = contentInset
            self.scrollView.scrollIndicatorInsets = contentInset
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        DispatchQueue.main.async {
            self.scrollView.contentInset = .zero
            self.scrollView.scrollIndicatorInsets = .zero
        }
    }

}
