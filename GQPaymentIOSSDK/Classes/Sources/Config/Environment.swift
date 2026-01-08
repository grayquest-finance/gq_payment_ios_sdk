//
//  Environment.swift
//  GQPaymentIOSSDK
//
//  Created by Avinash Soni on 08/01/24.
//

import Foundation

//MARK: A Class for maintaining User credentials during SDK Runtime
class Environment {
    
    // Singleton instance of the class
    static let shared = Environment()
    
    private init() {}
    
    // MARK: Properties
    var env: String = "test"
    var gqApiKey: String = ""
    var clientID: String = ""
    var clientSecret: String = ""
    var abase: String = ""
    var customerNumber: String = ""
    var customerID: Int = 0
    var customerCode: String = ""
    var customerType: String = "new"
    var studentID: String = ""
    var theme: String = ""
    var customizationString: String = ""
    var ppConfigString: String = ""
    var feeHeadersString: String = ""
    var feeHeadersSplitString: String?
    var paymentMethods: String?
    var referenceID: String?
    var emiPlanID: String?
    var udfDetailsString: String?
//    var authToken: String?
    
    
    // MARK: Juspay Callback URL
    var juspayCallbackURL: String {
        switch env {
        case "stage":
//            return "svc-dp.stage.graydev.in"
            return "svc-dp-stage.graydev.tech"
        case "preprod":
            return "svc-dp.ppd.graydev.in"
        case "live":
            return "svc-dp.grayquest.com"
        default:
            return "svc-dp.uat.graydev.in"
        }
    }
    
    // MARK: Properties
    static var source: String = "isdk"
    static var version: String = "\"1.1\""
    static var customerAPI: String = "v1/customer/create-customer"
    static var sessionCodeAPI: String = "v1/pp/get-session-data"
    
    
    // MARK: Method to update environment
    func update(environment: String) {
        self.env = environment
    }
    
    // MARK: Method to update api key
    func updateApiKey(apiKey: String){
        self.gqApiKey = apiKey
    }
    
    // MARK: Method to update client ID
    func updateClientId(clientID: String){
        self.clientID = clientID
    }
    
    // MARK: Method to update client secret
    func updateClientSecret(clientSecret: String){
        self.clientSecret = clientSecret
    }
    
    // MARK: Method to update abase
    func updateAbase(abase: String){
        self.abase = abase
    }
    
    // MARK: Method to update customer number
    func updateCustomerNumber(customerNumber: String){
        self.customerNumber = customerNumber
    }
    
    // MARK: Method to update customer ID
    func updateCustomerId(custId: Int){
        self.customerID = custId
    }
    
    // MARK: Method to update customer code
    func updateCustomerCode(custCode: String){
        self.customerCode = custCode
    }
    
    // MARK: Method to update customer type
    func updateCustomerType(custType: String){
        self.customerType = custType
    }
    
    // MARK: Method to update student ID
    func updateStudentID(stdId: String){
        self.studentID = stdId
    }
    
    // MARK: Method to update the theme
    func updateTheme(theme: String){
        self.theme = theme
    }
    
    // MARK: Method to update the customization object
    func updateCustomization(customization: String){
        self.customizationString = customization
    }
    
    // MARK: Method to update ppConfig
    func updatePpConfig(ppConfig: String){
        self.ppConfigString = ppConfig
    }
    
    // MARK: Method to update fee headers
    func updateFeeHeaders(feeHeader: String){
        self.feeHeadersString = feeHeader
    }
    
    // MARK: Method to update fee headers split
    func updateFeeHeadersSplit(feeHeaderSplitString: String) {
        self.feeHeadersSplitString = feeHeaderSplitString
    }
    
    // MARK: Method to update payment methods
    func updatePaymentMethods(paymentMethods: String) {
        self.paymentMethods = paymentMethods
    }
    
    // MARK: Method to update reference ID
    func updateReferenceID(referenceID: String?) {
        self.referenceID = referenceID
    }

    // MARK: Method to update emi plan ID
    func updateEmiPlanID(emiPlanID: String?) {
        self.emiPlanID = emiPlanID
    }

    // MARK: Method to update udf details
    func updateUDFDetails(udfDetails: String?) {
        self.udfDetailsString = udfDetails
    }
    
//    func updateAuthToken(authToken: String?) {
//        self.authToken = authToken
//    }
    
    // MARK: The Base URL for different environments
    func baseURL() -> String{
//        http://erp-sdk.uat.graydev.in
        switch env{
        case "stage":
//            return "https://erp-api.stage.graydev.in/"
            return "https://erp-api-stage.graydev.tech/"
        case "preprod":
            return "https://erp-api.ppd.graydev.in/"
        case "live":
            return "https://erp-api.grayquest.com/"
        default:
            return "https://erp-api.uat.graydev.in/"
        }
    }
    
    // MARK: The Web URL for different environments
    func webLoadURL() -> String{
        switch env{
        case "stage":
//            return "https://erp-sdk.stage.graydev.in/"
            return "https://erp-sdk-stage.graydev.tech/"
        case "preprod":
            return "https://erp-sdk.ppd.graydev.in/"
        case "live":
            return "https://erp-sdk.grayquest.com/"
        default:
            return "https://erp-sdk.uat.graydev.in/"
        }
    }
}
