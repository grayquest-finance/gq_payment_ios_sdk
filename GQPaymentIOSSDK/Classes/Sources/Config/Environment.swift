//
//  Environment.swift
//  GQPaymentIOSSDK
//
//  Created by Avinash Soni on 08/01/24.
//

import Foundation

class Environment {
    
    static let shared = Environment()
    
    private init() {}
    
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
    
    static var source: String = "isdk"
    static var version: String = "\"1.1\""
    static var customerAPI: String = "v1/customer/create-customer"
    static var sessionCodeAPI: String = "v1/pp/get-session-data"
    
    // Method to update values
    func update(environment: String) {
        self.env = environment
    }
    
    func updateApiKey(apiKey: String){
        self.gqApiKey = apiKey
    }
    
    func updateClientId(clientID: String){
        self.clientID = clientID
    }
    
    func updateClientSecret(clientSecret: String){
        self.clientSecret = clientSecret
    }
    
    func updateAbase(abase: String){
        self.abase = abase
    }
    
    func updateCustomerNumber(customerNumber: String){
        self.customerNumber = customerNumber
    }
    
    func updateCustomerId(custId: Int){
        self.customerID = custId
    }
    
    func updateCustomerCode(custCode: String){
        self.customerCode = custCode
    }
    
    func updateCustomerType(custType: String){
        self.customerType = custType
    }
    
    func updateStudentID(stdId: String){
        self.studentID = stdId
    }
    
    func updateTheme(theme: String){
        self.theme = theme
    }
    
    func updateCustomization(customization: String){
        self.customizationString = customization
    }
    
    func updatePpConfig(ppConfig: String){
        self.ppConfigString = ppConfig
    }
    
    func updateFeeHeaders(feeHeader: String){
        self.feeHeadersString = feeHeader
    }
    
    func updateFeeHeadersSplit(feeHeaderSplitString: String) {
        self.feeHeadersSplitString = feeHeaderSplitString
    }
    
    func updatePaymentMethods(paymentMethods: String) {
        self.paymentMethods = paymentMethods
    }
    
    func updateReferenceID(referenceID: String?) {
        self.referenceID = referenceID
    }

    func updateEmiPlanID(emiPlanID: String?) {
        self.emiPlanID = emiPlanID
    }

    func updateUDFDetails(udfDetails: String?) {
        self.udfDetailsString = udfDetails
    }
    
//    func updateAuthToken(authToken: String?) {
//        self.authToken = authToken
//    }
    
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
