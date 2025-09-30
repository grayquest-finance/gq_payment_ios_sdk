//
//  GQPaymentSDK.swift
//  GQPaymentIOSSDK
//
//  Created by Avinash Soni on 08/01/24.
//

import Foundation
import UIKit
import CashfreePG

public class GQPaymentSDK: GQViewController, WebDelegate {
    
    public var delegate: GQPaymentDelegate?
    let customInstance = Custom()
    var environment = Environment.shared
    
    public var clientJSONObject: [String: Any]?
    public var prefillJSONObject: [String: Any]?
    private var mobileNumber: String = ""
    private var errorMessage: String = ""
    private var isInValid: Bool = false
    
    // Auth Token
    public var token: String?
    // Environment to be used with Auth token
    public var env: String = "" {
        didSet {
            guard clientJSONObject?.isEmpty ?? true else { return }
            environment.update(environment: env)
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        showLoader()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        redirectToWebSDK()
    }
    
    private func redirectToWebSDK() {
        Task(priority: .userInitiated) {
            do {
                if let token {
                    let webURL = try await fetchURLFromSessionCode(token: token)
                    redirectToGQWebView(webloadUrl: webURL)
                } else {
                    let webURL = try await getURLFromEnvironmentData()
                    redirectToGQWebView(webloadUrl: webURL)
                }
            } catch (let error) {
                handleError(message: error.localizedDescription)
            }
        }
    }
    
    @MainActor private func handleError(message: String) {
        let errorObject: [String: Any] = [
            "error": message
        ]
        self.dismiss(animated: true) {
            self.delegate?.gqFailureResponse(data: errorObject)
        }
    }
    
    @MainActor private func redirectToGQWebView(webloadUrl: String?) {
        let gqWebView = GQWebView()
        gqWebView.webDelegate = self
        gqWebView.loadURL = webloadUrl
        
        let navigationController = UINavigationController(rootViewController: gqWebView)
        navigationController.isModalInPresentation = true
        
        self.present(navigationController, animated: true, completion: nil)
        self.hideLoader()
    }
    
    func eraseEnvironment (){
        
        environment.update(environment: "test")
        environment.updateClientId(clientID: "")
        environment.updateClientSecret(clientSecret: "")
        environment.updateApiKey(apiKey: "")
        environment.updateAbase(abase: "")
        environment.updateCustomerNumber(customerNumber: "")
        environment.updateCustomerId(custId: 0)
        environment.updateCustomerCode(custCode: "")
        environment.updateCustomerType(custType: "")
        environment.updateStudentID(stdId: "")
        environment.updateTheme(theme: "")
        environment.updateCustomization(customization: "")
        environment.updatePpConfig(ppConfig: "")
        environment.updateFeeHeaders(feeHeader: "")
    }
    
    func sdSuccess(data: [String : Any]?) {
        self.hideLoader()
        delegate?.gqSuccessResponse(data: data)
    }
    
    func sdCancel(data: [String : Any]?) {
        self.dismiss(animated: true) {
            self.delegate?.gqCancelResponse(data: data)
        }
    }
    
    func sdError(data: [String : Any]?) {
        self.hideLoader()
        delegate?.gqFailureResponse(data: data)
    }
}


//MARK: Login using Auth Token and Environment
extension GQPaymentSDK {
    
    private func fetchURLFromSessionCode(token: String) async throws -> String? {
        try validateForAuthToken(token: token)
        let sessionResponse = try await APIService.fetchSessionCode(token: token)
        return fetchSessionWebURL(response: sessionResponse)
    }
    
    private func fetchSessionWebURL(response: [String: Any]?) -> String? {
        guard let response,
              let data = response["data"] as? [String: Any],
              let sessionCode = data["session_code"] as? String
        else {
            return nil
        }
        
        var webloadUrl = self.environment.webLoadURL()
        webloadUrl += "instant-eligibility?_code=\(sessionCode)"
        webloadUrl += "&s=\(Environment.source)"
        webloadUrl += "&_v=\(Environment.version)"
        
        return webloadUrl
    }
    
    private func validateForAuthToken(token: String?) throws {
        var errorMessage: [String] = []
        
        if token?.isEmpty ?? true {
            errorMessage.append("Token is required")
        }
        
        if !customInstance.containsAnyValidEnvironment(env) {
            errorMessage.append("Invalid environment")
        }
        
        if !errorMessage.isEmpty {
            throw GQError.validationError(errorMessage.joined(separator: ", "))
        }
    }
}


//MARK: Login using Config Object and Prefill Object
extension GQPaymentSDK {
    
    private func getURLFromEnvironmentData() async throws -> String? {
        if let jsonString = customInstance.convertDictionaryToJson(dictionary: clientJSONObject ?? ["error":"Invalid JSON Object"]) {
            eraseEnvironment()
            if let jsonData = jsonString.data(using: .utf8) {
                do {
                    if let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                        // Accessing values
                        if let auth = json["auth"] as? [String: Any],
                           let clientId = auth["client_id"] as? String,
                           let clientSecret = auth["client_secret_key"] as? String,
                           let apiKey = auth["gq_api_key"] as? String {
                            environment.updateClientId(clientID: clientId)
                            environment.updateClientSecret(clientSecret: clientSecret)
                            environment.updateApiKey(apiKey: apiKey)
                            let abase = customInstance.encodeStringToBase64(environment.clientID+":"+environment.clientSecret)
                            
                            environment.updateAbase(abase: abase!)
                        } else {
                            isInValid = true
                            errorMessage += "Auth is missing"
                        }
                        
                        if let studentID = json["student_id"] as? String, !studentID.isEmpty {
                            environment.updateStudentID(stdId: studentID)
                        }else {
                            isInValid = true
                            errorMessage += ", Student Id is required"
                        }
                        
                        if let referenceID = json["reference_id"] as? String {
                            environment.updateReferenceID(referenceID: referenceID)
                        }
                        
                        if let emiPlanID = json["emi_plan_id"] as? String {
                            environment.updateEmiPlanID(emiPlanID: emiPlanID)
                        }
                        
                        if let udfDetails = json["udf_details"] as? [String: Any] {
                            if let udfDetailsString = customInstance.outputJSON(dictionary: udfDetails) {
                                environment.updateUDFDetails(udfDetails: udfDetailsString)
                            }
                        }
                        
                        if let env = json["env"] as? String {
                            if customInstance.containsAnyValidEnvironment(env){
                                environment.update(environment: env)
                            }else{
                                isInValid = true
                                errorMessage += ", Invalid environment"
                            }
                        }else{
                            isInValid = true
                            errorMessage += ", Environment is required"
                        }
                        
                        if let customization = json["customization"] as? [String: Any] {
                            if let themeColor = customization["theme_color"] as? String {
                                environment.updateTheme(theme: themeColor)
                            }
                        }
                        
                        if let ppConfig = json["pp_config"] as? [String: Any]{
                            if let slug = ppConfig["slug"] as? String, !slug.isEmpty {
                                if let ppConfigData = try? JSONSerialization.data(withJSONObject: ppConfig as Any, options: .prettyPrinted),
                                   let ppConfigString = String(data: ppConfigData, encoding: .utf8) {
                                    environment.updatePpConfig(ppConfig: ppConfigString)
                                } else {
                                    isInValid = true
                                    errorMessage += ", Invalid PP Config Object"
                                }
                            } else {
                                isInValid = true
                                errorMessage += ", Slug is required"
                            }
                        }
                        
                        if let feeHeaders = json["fee_headers"] as? [String: Any]{
                            if let feeHeadersData = try? JSONSerialization.data(withJSONObject: feeHeaders as Any, options: .prettyPrinted),
                               let feeHeadersString = String(data: feeHeadersData, encoding: .utf8) {
                                environment.updateFeeHeaders(feeHeader: feeHeadersString)
                            } else {
                                isInValid = true
                                errorMessage += ", Invalid Fee Headers Object"
                            }
                        }
                        
                        if let feeHeadersSplit = json["fee_headers_split"] as? [String: Any] {
                            if let feeHeadersSplitData = try? JSONSerialization.data(withJSONObject: feeHeadersSplit, options: .prettyPrinted),
                               let feeHeadersSplitString = String(data: feeHeadersSplitData, encoding: .utf8) {
                                environment.updateFeeHeadersSplit(feeHeaderSplitString: feeHeadersSplitString)
                            }
                        }
                        
                        if let paymentMethods = json["payment_methods"] as? String {
                            environment.updatePaymentMethods(paymentMethods: paymentMethods)
                        }
                        
                        if let customerNumber = json["customer_number"] as? String {
                            if customInstance.validate(value: customerNumber){
                                environment.updateCustomerNumber(customerNumber: customerNumber)
                                mobileNumber = customerNumber
                                
                                
                            }else{
                                isInValid = true
                                errorMessage += ", Invalid customer number"
                            }
                        }
                    } else {
                        isInValid = true
                        errorMessage += ", Invalid JSON Object"
                    }
                } catch {
                    isInValid = true
                    errorMessage += ", Invalid JSON Object"
                }
            } else {
                isInValid = true
                errorMessage += ", Invalid JSON Object"
            }
        } else {
            isInValid = true
            errorMessage += ", Invalid JSON Object"
        }
        
        if isInValid {
            throw GQError.validationError(errorMessage)
        } else {
            if mobileNumber.isEmpty{
                environment.updateCustomerType(custType: "new")
                return getURL()
            } else {
                let webURL = try await getURLFromCreateCustomer()
                return webURL
            }
        }
    }
    
    private func getURLFromCreateCustomer() async throws -> String? {
        let responseObject = try await APIService.performCreateCustomer()
        return handleAPIResult(responseObject: responseObject)
    }
    
    private func handleAPIResult(responseObject: [String: Any]?) -> String? {
        guard let responseObject = responseObject else {
            return nil
        }
        
        let message = responseObject["message"] as! String
        
        if (message == "Customer Exists") {
            self.environment.updateCustomerType(custType: "existing")
        }
        else {
            self.environment.updateCustomerType(custType: "new")
        }
        
        let data = responseObject["data"] as! [String:AnyObject]
        self.environment.updateCustomerCode(custCode: data["customer_code"] as! String)
        self.environment.updateCustomerId(custId: data["customer_id"] as! Int)
        
        return getURL()
    }
    
    private func getURL() -> String {
        
        var webloadUrl: String = ""
        
        let baseURL = self.environment.webLoadURL()
        
        webloadUrl = baseURL
        
        webloadUrl += "instant-eligibility?gapik=\(environment.gqApiKey)"
        
        webloadUrl += "&abase=\(environment.abase)"
        
        webloadUrl += "&sid=\(environment.studentID)"
        
        if !environment.customerNumber.isEmpty{
            webloadUrl += "&m=\(environment.customerNumber)"
        }
        
        webloadUrl += "&env=\(environment.env)"
        
        if environment.customerID != 0{
            webloadUrl += "&cid=\(environment.customerID)"
        }
        
        if !environment.customerCode.isEmpty {
            webloadUrl += "&ccode=\(environment.customerCode)"
        }
        
        if !environment.theme.isEmpty {
            webloadUrl += "&pc=\(environment.theme)"
        }
        
        webloadUrl += "&s=\(Environment.source)"
        webloadUrl += "&user=\(environment.customerType)"
        
        if !environment.ppConfigString.isEmpty {
            webloadUrl += "&_pp_config=\(environment.ppConfigString)"
        }
        
        if !environment.feeHeadersString.isEmpty {
            webloadUrl += "&_fee_headers=\(environment.feeHeadersString)"
        }
        
        if let referenceID = environment.referenceID, !referenceID.isEmpty {
            webloadUrl += "&reference_id=\(referenceID)"
        }
        
        if let emiPlanID = environment.emiPlanID, !emiPlanID.isEmpty {
            webloadUrl += "&emi_plan_id=\(emiPlanID)"
        }
        
        if let udfDetails = environment.udfDetailsString, !udfDetails.isEmpty {
            webloadUrl += "&udf_details=\(udfDetails)"
        }
        
        // Adding Payment Methods
        if let paymentMethods = environment.paymentMethods {
            webloadUrl += "&payment_methods=\(paymentMethods)"
        }
        
        // Adding Fee Headers Split
        if let feeHeadersSplitString = environment.feeHeadersSplitString, !feeHeadersSplitString.isEmpty {
            webloadUrl += "&fee_headers_split=\(feeHeadersSplitString)"
        }
        
        if let prefillJSONObject = prefillJSONObject {
            if let optionalString = customInstance.convertDictionaryToJson(dictionary: prefillJSONObject),
               !optionalString.isEmpty {
                webloadUrl += "&optional=\(optionalString)"
            }
        }
        
        webloadUrl += "&_v=\(Environment.version)"
        
        return webloadUrl
    }
}
