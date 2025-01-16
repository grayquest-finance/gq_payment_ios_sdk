//
//  GQWebView.swift
//  GQPaymentIOSSDK
//
//  Created by Avinash Soni on 08/01/24.
//

import Foundation
import UIKit
@preconcurrency import WebKit
import CashfreePGCoreSDK
import CashfreePGUISDK
import CashfreePG
import Razorpay
import Easebuzz

class GQWebView: GQViewController, CFResponseDelegate, RazorpayPaymentCompletionProtocolWithData, PayWithEasebuzzCallback, WKUIDelegate, WKScriptMessageHandler, WKNavigationDelegate {
    
    let environment = Environment.shared
    var paymentSessionId: String?
    var orderId: String?
    let customInstance = Custom()
    public var delegate: GQPaymentDelegate?
    var webDelegate: WebDelegate?
    var webView: WKWebView!
    let pgService = CFPaymentGatewayService.getInstance()
    var razorpay: RazorpayCheckout!
    
    var callBackUrl: String?
    var vName: String?
    var loadURL: String?
//    var isUNIPGError: Bool = false
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.hideLoader()
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .linkActivated {
            print(navigationAction.request)
            if let url = navigationAction.request.url, UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
            decisionHandler(.cancel)
            return
        }
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.hideLoader()
    }
        
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        guard let url = navigationAction.request.url else { return nil }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
        return nil
    }
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
//        print("Received message from web -> \(message.body)")
        if (message.name == "sdkSuccess") {
            do {
                let data = message.body as! String
                let con = try JSONSerialization.jsonObject(with: data.data(using: .utf8)!, options: []) as! [String: Any]
//                print("sdkSuccess: \(con)")
//                print("sdkSuccessdata: \(data)")
                webDelegate?.sdSuccess(data: con)
            } catch {
//                print(error)
                self.dismiss(animated: true, completion: nil)
            }
        }else  if (message.name == "sdkError") {
            do {
                let data = message.body as! String
                let con = try JSONSerialization.jsonObject(with: data.data(using: .utf8)!, options: []) as! [String: Any]
                //                print("sdkError: \(con)")
                //                print("sdkErrordata: \(data)")
//                if !isUNIPGError {
                    webDelegate?.sdError(data: con)
//                }
                //                delegate?.gqSuccessResponse(data: con)
            } catch {
//                print(error)
                //                delegate?.gqErrorResponse(error: true, message: error.localizedDescription)
                self.dismiss(animated: true, completion: nil)
            }
        }else if (message.name == "sdkCancel") {
            do {
                let data = message.body as! String
                let con = try JSONSerialization.jsonObject(with: data.data(using: .utf8)!, options: []) as? [String: Any]
//                print("sdkCancel: \(con)")
                webDelegate?.sdCancel(data: con)
                self.dismiss(animated: true, completion: nil)
            } catch {
//                print(error)
                self.dismiss(animated: true, completion: nil)
            }
        }else if (message.name == "sendPGOptions") {
            let data = message.body as! String
            
            if let jsonData = data.data(using: .utf8) {
                do {
                    if let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any],
                       let name = json["name"] as? String{
                        
                        vName = name
//                        print("Name: \(vName)")
                        
                        if name == "CASHFREE"{
                            if let pgOptions = json["pgOptions"] as? [String: Any],
                               let orderCode1 = pgOptions["order_code"] as? String,
                               let mdMappingCode = pgOptions["md_mapping_code"] as? String,
                               let paymentSessionId1 = pgOptions["payment_session_id"] as? String {
                                
                                paymentSessionId = paymentSessionId1
                                orderId = orderCode1
                                
                                // Use the extracted values
//                                print("Name: \(name)")
//                                print("Order Code: \(orderCode1)")
//                                print("MD Mapping Code: \(mdMappingCode)")
//                                print("Payment Session ID: \(paymentSessionId1)")
                                
                                DispatchQueue.main.async {
                                    self.openPG(paymentSessionId: paymentSessionId1, orderId: orderCode1)
                                }
                            }
                        } else if name == "EASEBUZZ"{
                            if let pgOptions = json["pgOptions"] as? [String: Any],
                               let access_key = pgOptions["access_key"] as? String{
//                                print("Easebuz Key: \(access_key)")
                                
                                initiatePaymentAction(access_key: access_key)
                            }
                        } else if name == "HDFC-SMART-GATEWAY" {
                            if let pgOptions = json["pgOptions"] as? [String: Any], let paymentLink = pgOptions["payment_link_web"] as? String {
                                navigateToPaymentPage(link: paymentLink)
                            }
                        } else if let pgOptions = json["pgOptions"] as? [String: Any],
                                  let key = pgOptions["key"] as? String,
                                  let order_id = pgOptions["order_id"] as? String,
                                  var redirect = pgOptions["redirect"] as? Bool,
                                  let prefillObj = pgOptions["prefill"] as? [String: Any],
                                  let notes = pgOptions["notes"] as? [String: Any] {
                            let name = prefillObj["name"] as? String
                            let email = prefillObj["email"] as? String
                            let contact = prefillObj["contact"] as? String
                            
//                            print("key: \(key)")
                            
                            razorpay = RazorpayCheckout.initWithKey(key, andDelegateWithData: self)
                            
                            let options: [String:Any] = [
                                "order_id": order_id,
                                "recurring": 0,
                                "redirect": redirect,
                                "notes": notes,
                                "retry": [
                                    "enabled": true,
                                    "max_count": 4
                                ],
                                "prefill": [
                                    "contact": contact,
                                    "email": email
                                ]
                            ]
                            DispatchQueue.main.async {
                                self.razorpay!.open(options, displayController: self)
                            }
                        }
                    }
                } catch {
//                    print("Error parsing JSON: \(error)")
                }
            }
        }else if (message.name == "sendADOptions") {
            let data = message.body as! String
            if let jsonData = data.data(using: .utf8) {
                do {
                    if let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any],
                       let key = json["key"] as? String,
                       let customer_id = json["customer_id"] as? String,
                       let order_id = json["order_id"] as? String,
                       let recurring = json["recurring"] as? String,
                       let redirect = json["redirect"] as? Bool,
                       let callback_url = json["callback_url"] as? String,
                       let notes = json["notes"] as? [String: Any]{
//                        print("AdKey: \(key)")
                        callBackUrl = callback_url
                        
                        razorpay = RazorpayCheckout.initWithKey(key, andDelegateWithData: self)
                        
                        var recuring_flag: Bool = false
                        
                        if recurring == "1"{
                            recuring_flag = true
                        }
                        let options: [String:Any] = [
                            "customer_id": customer_id,
                            "order_id": order_id,
                            "recurring": recuring_flag,
                            "redirect": redirect,
                            "notes": notes,
                            "retry": [
                                "enabled": true,
                                "max_count": 4
                            ],
                        ]
                        DispatchQueue.main.async {
                            self.razorpay!.open(options, displayController: self)
                        }
                    }
                } catch {
//                    print("Error parsing JSON: \(error)")
                }
            }
        }
    }
    
//    public override func viewDidAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        //        self.showPaymentForm()
//    }
    
    public override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.preferences.javaScriptCanOpenWindowsAutomatically = true
        
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.configuration.userContentController.add(self, name: "Gqsdk")
        webView.configuration.userContentController.add(self, name: "sdkSuccess")
        webView.configuration.userContentController.add(self, name: "sdkError")
        webView.configuration.userContentController.add(self, name: "sdkCancel")
        webView.configuration.userContentController.add(self, name: "sendADOptions")
        webView.configuration.userContentController.add(self, name: "sendPGOptions")
        
//        #if DEBUG
        if #available(iOS 16.4, *) {
            webView.isInspectable = true
        }
//        #endif
        
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.scrollView.bounces = false
        
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.showLoader()
        pgService.setCallback(self)
        
        let environment = Environment.shared
//        print("Global Env: \(environment.env)")
        //
        //        let myURL = URL(string:"https://erp-sdk.graydev.tech/instant-eligibility?gapik=b59bf799-2a82-4298-b901-09c512ea4aaa&abase=R1EtMGQyZWQyNGUtY2MxZi00MDBiLWE0ZTMtNzIwOGM4OGI5OWI1OmE5NmRkN2VhLTdkNGEtNDc3Mi05MmMzLWFjNDgxNzEzYmU0YQ==&sid=demo_12345&m=8625960119&env=test&cid=34863&ccode=0a6c1b84-0cd7-4844-8f77-cd1807520273&pc=&s=asdk&user=existing&_v=\"1.1\"")
        
        if let urlString = loadURL?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let myURL = URL(string: urlString) {
            let myRequest = URLRequest(url: myURL)
            webView.load(myRequest)
        } else {
            if let myURL = URL(string: "https://grayquest.com") {
                let myRequest = URLRequest(url: myURL)
                webView.load(myRequest)
            } else {
                print("GQPaymentSDK: Invalid URL Found")
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func openPG(paymentSessionId: String, orderId: String) {
        
        do {
            let session = try CFSession.CFSessionBuilder()
                .setPaymentSessionId(paymentSessionId)
                .setOrderID(orderId)
                .setEnvironment(Environment.shared.env == "live" || Environment.shared.env == "preprod" ? .PRODUCTION : .SANDBOX)
                .build()
            
            // Set Components
            let paymentComponents = try CFPaymentComponent.CFPaymentComponentBuilder()
                .enableComponents([
                    "order-details",
                    "card",
                    "paylater",
                    "wallet",
                    "emi",
                    "netbanking",
                    "upi"
                ])
                .build()
            
            // Set Theme
            let theme = try CFTheme.CFThemeBuilder()
                .setNavigationBarBackgroundColor("#4563cb")
                .setNavigationBarTextColor("#FFFFFF")
                .setButtonBackgroundColor("#4563cb")
                .setButtonTextColor("#FFFFFF")
                .setPrimaryTextColor("#000000")
                .setSecondaryTextColor("#000000")
                .build()
            
            let webCheckoutPayment = try CFDropCheckoutPayment.CFDropCheckoutPaymentBuilder()
                .setSession(session).setComponent(paymentComponents).setTheme(theme)
                .build()
            try pgService.doPayment(webCheckoutPayment, viewController: self)
        } catch let e {
            let err = e as! CashfreeError
//            print(err.description)
        }
    }
    
    func onPaymentError(_ code: Int32, description str: String, andData response: [AnyHashable : Any]?) {
        var userInfo = response as NSDictionary? as? [String: Any]
        if ((callBackUrl?.isEmpty) != nil){
            userInfo?["callback_url"] = callBackUrl
        }
//        print("ErrorCode: \(code)")
//        print("ErrorDescription: \(str)")
//        print("ErrorResponse: \(String(describing: userInfo))")
        
        if let jsonString = customInstance.convertDictionaryToJson(dictionary: userInfo!) {
//            print("JSON String: \(jsonString)")
            if (vName == "UNIPG") {
//                print("VName: \(String(describing: vName))")
//                isUNIPGError = true
                webView.evaluateJavaScript("javascript:sendPGPaymentResponse(\(jsonString));")
            }else {
//                print("VNameCash; \(String(describing: vName))")
                webView.evaluateJavaScript("javascript:sendADPaymentResponse(\(jsonString));")
            }
            
        } else {
            print("Conversion to JSON failed.")
        }
    }
    
    func onPaymentSuccess(_ payment_id: String, andData response: [AnyHashable : Any]?) {
        var userInfo = response as NSDictionary? as? [String: Any]
        if ((callBackUrl?.isEmpty) != nil){
            userInfo?["callback_url"] = callBackUrl
        }
//        print("success: ", response)
        let paymentId = response?["razorpay_payment_id"] as! String
        let rezorSignature = response?["razorpay_signature"] as! String
//        print("SuccessPaymentID: \(payment_id)")
//        print("SuccessResponse: \(userInfo)")
        
        if let jsonString = customInstance.convertDictionaryToJson(dictionary: userInfo!) {
//            print("JSON String: \(jsonString)")
            if (vName == "UNIPG") {
//                print("VName: \(String(describing: vName))")
                webView.evaluateJavaScript("javascript:sendPGPaymentResponse(\(jsonString));")
            }else {
//                print("VNameCash; \(String(describing: vName))")
                webView.evaluateJavaScript("javascript:sendADPaymentResponse(\(jsonString));")
            }
            
        } else {
            print("Conversion to JSON failed.")
        }
    }
    
    func onError(_ error: CashfreePGCoreSDK.CFErrorResponse, order_id: String) {
//        print("ErrorResponse: ")
//        print(order_id)
//        print(error.status)
//        print(error.message)
        let paymentResponse: [String: Any] = [
            "status": error.status,
            "order_code": order_id,
            "message": error.message,
            "code": error.code,
            "type": error.type
        ]
//        print("SuccessResponse: ")
//        print(order_id)
        if let jsonString = customInstance.convertDictionaryToJson(dictionary: paymentResponse) {
//            print("JSON String: \(jsonString)")
            webView.evaluateJavaScript("javascript:sendPGPaymentResponse(\(jsonString));")
            
        } else {
            print("Conversion to JSON failed.")
        }
    }
    
    func verifyPayment(order_id: String) {
        let paymentResponse: [String: Any] = [
            "status": "SUCCESS",
            "order_code": order_id
        ]
//        print("SuccessResponse: ")
//        print(order_id)
        if let jsonString = customInstance.convertDictionaryToJson(dictionary: paymentResponse) {
//            print("JSON String: \(jsonString)")
            webView.evaluateJavaScript("javascript:sendPGPaymentResponse(\(jsonString));")
        } else {
//            print("Conversion to JSON failed.")
        }
    }
    
    @MainActor func navigateToPaymentPage(link: String?) {
        guard let link else { return }
        
//        MARK: Redirection
        let gqWebView = GQWeb()
        gqWebView.loadURL = link
        
//        #warning("remove static link and change bundle identifier")
//        gqWebView.loadURL = "https://payments.cashfree.com/links/c7v73bt760q0"
        
        self.navigationController?.pushViewController(gqWebView, animated: true)
        
        
//        MARK: Deep Linking
//        if let url = URL(string: link) {
//            if UIApplication.shared.canOpenURL(url) {
//                UIApplication.shared.open(url)
//            }
//        }
    }
    
    func initiatePaymentAction(access_key: String) {
        var orderDetails = [
            "access_key": access_key
        ] as [String:String]
//        if environment.env == "live", environment.env == "preprod" {
//            orderDetails["pay_mode"] = "production"
//        }else {
//            orderDetails["pay_mode"] = "test"
//        }
        
        orderDetails["pay_mode"] = "production"
//        print("orderDetails: \(orderDetails)")
        let payment = Payment.init(customerData: orderDetails)
        let paymentValid = payment.isValid().validity
        if !paymentValid {
//            print("Invalid records")
        }else{
            PayWithEasebuzz.setUp(pebCallback: self )
            PayWithEasebuzz.invokePaymentOptionsView(paymentObj: payment, isFrom: self)
        }
    }
    
    func PEBCallback(data: [String : AnyObject]) {
        let payment_response = data["payment_response"]
//        print(payment_response ?? "")
//        if payment_response as? [String:Any] != nil {
//            // payment_response is Json Response
//            print("Json response:\(payment_response)")
//        }else{
//            print("String response: \(payment_response)")
//        }
        // Handle result Key : It should be in string
        let result = data["result"] as! String
//        print("result: \(result)")
        
        var paymentResponse: [String: Any] = [:]
        
        if result == "payment_successfull"{
            paymentResponse["status"] = "SUCCESS"
        }else {
            paymentResponse["status"] = "FAILED"
        }
        paymentResponse["payment_response"] = payment_response
//        print("SuccessResponse: ")
        if let jsonString = customInstance.convertDictionaryToJson(dictionary: paymentResponse) {
//            print("JSON String: \(jsonString)")
            webView.evaluateJavaScript("javascript:sendPGPaymentResponse(\(jsonString));")
        } else {
//            print("Conversion to JSON failed.")
        }
    }
}
