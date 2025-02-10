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
    var paymentMethods: [String]?
    var referenceID: String?
    var emiPlanID: String?
    var udfDetailsString: String?
    
    var juspayCallbackURL: String {
        switch env {
        case "stage":
            return "svc-dp-stage.graydev.tech"
        case "preprod":
            return "svc-dp-preprod.graydev.tech"
        case "live":
            return "svc-dp.grayquest.com"
        default:
            return "svc-dp.graydev.tech"
        }
    }
    
    static var source: String = "isdk"
    static var version: String = "\"1.1\""
    static var customerAPI: String = "v1/customer/create-customer"
    
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
    
    func updatePaymentMethods(paymentMethods: [String]) {
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
    
    func baseURL() -> String{
        switch env{
        case "stage":
            return "https://erp-api-stage.graydev.tech/"
        case "preprod":
            return "https://erp-api-preprod.graydev.tech/"
        case "live":
            return "https://erp-api.grayquest.com/"
        default:
            return "https://erp-api.graydev.tech/"
        }
    }
    
    func webLoadURL() -> String{
        switch env{
        case "stage":
            return "https://erp-sdk-stage.graydev.tech/"
        case "preprod":
            return "https://erp-sdk-preprod.graydev.tech/"
        case "live":
            return "https://erp-sdk.grayquest.com/"
        default:
            return "https://erp-sdk.graydev.tech/"
        }
    }
}
