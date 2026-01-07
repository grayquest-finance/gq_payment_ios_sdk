//
//  GQPaymentSDK.swift
//  GQPaymentIOSSDK
//
//  Created by Avinash Soni on 08/01/24.
//

import Foundation
import UIKit
import CashfreePG

//MARK: An Intializing Class for calling the GQPaymentSDK
/// - Important: Always add value to `clientJSONObject` and `prefillJSONObject` for intitalising using ClientID, ClientSecret and API Key.
/// - Important: Always add value to `token` and `env` for initialising using authentication using token.
/// The `delegate` needs to be assigned to receive events.
/// The Parameters are the deciding factor in which function and API calls needs to done ahead.
public class GQPaymentSDK: GQViewController, WebDelegate {
    
    // MARK: The `delegate` that receives success, failure and error events.
    public var delegate: GQPaymentDelegate?
    
    // MARK: Common class for validation and encoding.
    let customInstance = Custom()
    
    // MARK: Shared Environment for data caching.
    var environment = Environment.shared
    
    // MARK: Properties
    public var clientJSONObject: [String: Any]?
    public var prefillJSONObject: [String: Any]?
    private var mobileNumber: String = ""
    private var errorMessage: String = ""
    private var isInValid: Bool = false
    
    // MARK: Auth Token for login using token.
    public var token: String?
    
    // MARK: Environment to be used with Auth token
    public var env: String = "" {
        didSet {
            guard clientJSONObject?.isEmpty ?? true else { return }
            environment.update(environment: env)
        }
    }
    
    // MARK: Displaying Loader for initial API Call. - Lifecycle View
    public override func viewDidLoad() {
        super.viewDidLoad()
        showLoader()
    }
    
    // MARK: Redirect to Webview based on given data. - Lifecycle View
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        redirectToWebSDK()
    }
    
    // MARK: Method to get URL based on given data and fetching.
    // Performs API call to generate URL based on data received.
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
    
    // MARK: Method to handle Error messages.
    //         - parameters:
    //                webloadUrl - URL in String format
    @MainActor private func handleError(message: String) {
        let errorObject: [String: Any] = [
            "error": message
        ]
        self.dismiss(animated: true) {
            self.delegate?.gqFailureResponse(data: errorObject)
        }
    }
    
    // MARK: Function to open webview with the particular URL.
    //         - parameters:
    //                webloadUrl - URL in String format
    @MainActor private func redirectToGQWebView(webloadUrl: String?) {
        let gqWebView = GQWebView()
        gqWebView.webDelegate = self
        gqWebView.loadURL = webloadUrl
        
        let navigationController = UINavigationController(rootViewController: gqWebView)
        navigationController.isModalInPresentation = true
        
        self.present(navigationController, animated: true, completion: nil)
        self.hideLoader()
    }
    
    // MARK: Function to clear data in shared Environment.
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
    
    // MARK: WebDelegate Function to return Success events.
    //         - parameters:
    //                data - Events based on web
    func sdSuccess(data: [String : Any]?) {
        self.hideLoader()
        delegate?.gqSuccessResponse(data: data)
    }
    
    // MARK: WebDelegate Function to return Cancel events.
    //         - parameters:
    //                data - Events based on web
    func sdCancel(data: [String : Any]?) {
        self.dismiss(animated: true) {
            self.delegate?.gqCancelResponse(data: data)
        }
    }
    
    // MARK: WebDelegate Function to return Failure events.
    //         - parameters:
    //                data - Events based on web
    func sdError(data: [String : Any]?) {
        self.hideLoader()
        delegate?.gqFailureResponse(data: data)
    }
}


//MARK: Extension for Login using Auth Token and Environment
extension GQPaymentSDK {
    
    //MARK: Function for fetching Session Code from token.
    //         - parameters:
    //                token - token received from intialising class
    private func fetchURLFromSessionCode(token: String) async throws -> String? {
        try validateForAuthToken(token: token)
        let sessionResponse = try await APIService.fetchSessionCode(token: token)
        return fetchSessionWebURL(response: sessionResponse)
    }
    
    //MARK: Function to generate Web URL using response from token.
    //         - parameters:
    //                response - the response received from API call
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
    
    //MARK: Function to validate token and env for authentication.
    //         - parameters:
    //                token - token received from intialising class
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


//MARK: Extension for Login using Config Object and Prefill Object
extension GQPaymentSDK {
    
    //MARK: Function for saving data in shared Environment and creating URL.
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
    
    //MARK: Function for performing create customer API.
    private func getURLFromCreateCustomer() async throws -> String? {
        let responseObject = try await APIService.performCreateCustomer()
        return handleAPIResult(responseObject: responseObject)
    }
    
    //MARK: Function for handling API result and returning URL
    //         - parameters:
    //                token - token received from intialising class
    //         - return:
    //                 URL String
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
    
    //MARK: Function to generate URL based on shared environment
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
