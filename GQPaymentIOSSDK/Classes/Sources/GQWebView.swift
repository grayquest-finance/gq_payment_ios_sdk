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

//MARK: A Class for displaying webview
/// All the vendor SDKs delegate are applied here.
class GQWebView: GQViewController, CFResponseDelegate, RazorpayPaymentCompletionProtocolWithData, PayWithEasebuzzCallback, WKUIDelegate, WKScriptMessageHandler, WKNavigationDelegate {
    
    // MARK: Properties
    let environment = Environment.shared
    var paymentSessionId: String?
    var orderId: String?
    let customInstance = Custom()
    
    //MARK: The `delegate` needs to be assigned to receive events.
    public var delegate: GQPaymentDelegate?
    var webDelegate: WebDelegate?
    
    //MARK: Webview for displaying web contents
    var webView: WKWebView!
    
    //MARK: Cashfree Instance
    let pgService = CFPaymentGatewayService.getInstance()
    
    //MARK: Razorpay Instance
    var razorpay: RazorpayCheckout!
    
    // MARK: Properties
    var callBackUrl: String?
    var vName: String?
    var loadURL: String?
//    var isUNIPGError: Bool = false
    
    //MARK: Webview Delegate - On Webview Navigation Finish
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.hideLoader()
    }
    
    //MARK: Webview Delegate - On Webview Navigation Decision
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .linkActivated {
            if let url = navigationAction.request.url, UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
            decisionHandler(.cancel)
            return
        }
        decisionHandler(.allow)
    }
    
    //MARK: Webview Delegate - On Webview Navigation Fail
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.hideLoader()
    }
    
    //MARK: Webview Delegate - On Webview Navigation Action
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        guard let url = navigationAction.request.url else { return nil }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
        return nil
    }
    
    //MARK: Webview Delegate - On Webview Message/Event Finish
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if (message.name == "sdkSuccess") {         //MARK: Success Event
            do {
                let data = message.body as! String
                let con = try JSONSerialization.jsonObject(with: data.data(using: .utf8)!, options: []) as! [String: Any]
                webDelegate?.sdSuccess(data: con)
            } catch {
                self.dismissNavigationController(data: nil)
            }
        }else  if (message.name == "sdkError") {            //MARK: Failure Event
            do {
                let data = message.body as! String
                let con = try JSONSerialization.jsonObject(with: data.data(using: .utf8)!, options: []) as! [String: Any]
//                if !isUNIPGError {
                    webDelegate?.sdError(data: con)
//                }
            } catch {
                self.dismissNavigationController(data: nil)
            }
        }else if (message.name == "sdkCancel") {         //MARK: Cancel Event
            do {
                let data = message.body as! String
                let con = try JSONSerialization.jsonObject(with: data.data(using: .utf8)!, options: []) as? [String: Any]
                self.dismissNavigationController(data: con)
            } catch {
                self.dismissNavigationController(data: nil)
            }
        }else if (message.name == "sendPGOptions") {         //MARK: On Receive Payment Gateway Options Event
            let data = message.body as! String
            
            if let jsonData = data.data(using: .utf8) {
                do {
                    if let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                        let name = json["name"] as? String
                        vName = name
                        
                        if name == "CASHFREE"{                         //MARK: Cashfree SDK Launch
                            if let pgOptions = json["pgOptions"] as? [String: Any],
                               let orderCode1 = pgOptions["order_code"] as? String,
                               let mdMappingCode = pgOptions["md_mapping_code"] as? String,
                               let paymentSessionId1 = pgOptions["payment_session_id"] as? String {
                                
                                paymentSessionId = paymentSessionId1
                                orderId = orderCode1
                                
                                DispatchQueue.main.async {
                                    self.openPG(paymentSessionId: paymentSessionId1, orderId: orderCode1)
                                }
                            }
                        } else if name == "EASEBUZZ"{                         //MARK: Easebuzz SDK Launch
                            if let pgOptions = json["pgOptions"] as? [String: Any],
                               let access_key = pgOptions["access_key"] as? String{
                                
                                initiatePaymentAction(access_key: access_key)
                            }
                        } else if name == "UNIPG",
                                  let pgOptions = json["pgOptions"] as? [String: Any],
                                  let key = pgOptions["key"] as? String,
                                  let order_id = pgOptions["order_id"] as? String,
                                  var redirect = pgOptions["redirect"] as? Bool,
                                  let prefillObj = pgOptions["prefill"] as? [String: Any],
                                  let notes = pgOptions["notes"] as? [String: Any] {                         //MARK: UNIPG/Razorpay Detection
                            let name = prefillObj["name"] as? String
                            let email = prefillObj["email"] as? String
                            let contact = prefillObj["contact"] as? String
                            
                            
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
                        } else if let pgOptions = json["pgOptions"] as? [String: Any],
                              let paymentLink = pgOptions["payment_link_web"] as? String {
//                              MARK: Webcheckout page (Web Link)
                               navigateToPaymentPage(link: paymentLink)
                       }
                    }
                } catch {

                }
            }
        }else if (message.name == "sendADOptions") { //MARK: On Receive Auto Debit (Razorpay Vendor) events
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
                }
            }
        }
    }
    
//    public override func viewDidAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        //        self.showPaymentForm()
//    }
    
//MARK: Register Webview Events and Webview Configuration
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
    
    //MARK: Loading webview on valid URL - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.showLoader()
        pgService.setCallback(self)
        
        //        let myURL = URL(string:"https://erp-sdk.graydev.in/instant-eligibility?gapik=<KEY>&abase=<KEY>&sid=demo_12345&m=8625960119&env=test&cid=34863&ccode=<KEY>&pc=&s=asdk&user=existing&_v=\"1.1\"")
        
        if let urlString = loadURL?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let myURL = URL(string: urlString) {
            let myRequest = URLRequest(url: myURL)
            webView.load(myRequest)
        } else {
            if let myURL = URL(string: "https://grayquest.com") {
                let myRequest = URLRequest(url: myURL)
                webView.load(myRequest)
            } else {
            }
        }
        
    }
    
    //MARK: View Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    //MARK: Launch Cashfree SDK
    //         - parameters:
    //                paymentSessionId - The payment ID of the transaction
//                    orderId - The Order ID of the transaction
    func openPG(paymentSessionId: String, orderId: String) {
        
        do {
            let session = try CFSession.CFSessionBuilder()
                .setPaymentSessionId(paymentSessionId)
                .setOrderID(orderId)
                .setEnvironment(Environment.shared.env == "live" || Environment.shared.env == "preprod" ? .PRODUCTION : .SANDBOX)
                .build()
            
            let webCheckoutPayment = try CFWebCheckoutPayment.CFWebCheckoutPaymentBuilder()
                .setSession(session)
                .build()
            
            try pgService.doPayment(webCheckoutPayment, viewController: self)
        } catch let e {
            let err = e as! CashfreeError
        }
    }
    
    //MARK: On Dismiss of Navigation Controller
    //         - parameters:
    //                data - The data to be passed on SDK cancelled
    @MainActor private func dismissNavigationController(data: [String: Any]?) {
        self.navigationController?.dismiss(animated: true) {
            self.webDelegate?.sdCancel(data: data)
        }
    }
    
    //MARK: Razorpay Delegate Method - On Error
    func onPaymentError(_ code: Int32, description str: String, andData response: [AnyHashable : Any]?) {
        var userInfo = response as NSDictionary? as? [String: Any]
        if ((callBackUrl?.isEmpty) != nil){
            userInfo?["callback_url"] = callBackUrl
        }
        
        if let jsonString = customInstance.convertDictionaryToJson(dictionary: userInfo!) {
            if (vName == "UNIPG") {
//                isUNIPGError = true
                webView.evaluateJavaScript("javascript:sendPGPaymentResponse(\(jsonString));")
            }else {
                webView.evaluateJavaScript("javascript:sendADPaymentResponse(\(jsonString));")
            }
            
        }
    }
    
    //MARK: Razorpay Delegate Method - On Success
    func onPaymentSuccess(_ payment_id: String, andData response: [AnyHashable : Any]?) {
        var userInfo = response as NSDictionary? as? [String: Any]
        if ((callBackUrl?.isEmpty) != nil){
            userInfo?["callback_url"] = callBackUrl
        }
        let paymentId = response?["razorpay_payment_id"] as! String
        let rezorSignature = response?["razorpay_signature"] as! String
        
        if let jsonString = customInstance.convertDictionaryToJson(dictionary: userInfo!) {
            if (vName == "UNIPG") {
                webView.evaluateJavaScript("javascript:sendPGPaymentResponse(\(jsonString));")
            }else {
                webView.evaluateJavaScript("javascript:sendADPaymentResponse(\(jsonString));")
            }
            
        }
    }
    
    //MARK: Cashfree Delegate Method - On Error
    func onError(_ error: CashfreePGCoreSDK.CFErrorResponse, order_id: String) {
        let paymentResponse: [String: Any] = [
            "status": error.status ?? "",
            "order_code": order_id,
            "message": error.message ?? "",
            "code": error.code ?? "",
            "type": error.type ?? ""
        ]
        if let jsonString = customInstance.convertDictionaryToJson(dictionary: paymentResponse) {
            webView.evaluateJavaScript("javascript:sendPGPaymentResponse(\(jsonString));")
            
        }
    }
    
    //MARK: Cashfree Delegate Method - On Payment done event
    func verifyPayment(order_id: String) {
        let paymentResponse: [String: Any] = [
            "status": "SUCCESS",
            "order_code": order_id
        ]
        if let jsonString = customInstance.convertDictionaryToJson(dictionary: paymentResponse) {
            webView.evaluateJavaScript("javascript:sendPGPaymentResponse(\(jsonString));")
        } else {
        }
    }
    
    //MARK: For Weblink navigation to a new screen.
//    Ex. Easebuzz Web Link
    @MainActor func navigateToPaymentPage(link: String?) {
        guard let link else { return }
        
//        MARK: Redirection
        let gqWebView = GQWeb()
        gqWebView.loadURL = link
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.navigationController?.pushViewController(gqWebView, animated: true)
        
//        MARK: Deep Linking
//        if let url = URL(string: link) {
//            if UIApplication.shared.canOpenURL(url) {
//                UIApplication.shared.open(url)
//            }
//        }
    }
    
    //MARK: For Launching Easebuzz SDK.
//         - parameters:
//                access_key - The Access Key to pass to the SDK for functioning
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
        let payment = Payment.init(customerData: orderDetails)
        let paymentValid = payment.isValid().validity
        if !paymentValid {
        }else{
            PayWithEasebuzz.setUp(pebCallback: self )
            PayWithEasebuzz.invokePaymentOptionsView(paymentObj: payment, isFrom: self)
        }
    }
    
    //MARK: Easebuzz - Callback Function
    func PEBCallback(data: [String : AnyObject]) {
        let payment_response = data["payment_response"]
//        if payment_response as? [String:Any] != nil {
//            // payment_response is Json Response
//        }else{
//        }
        // Handle result Key : It should be in string
        let result = data["result"] as! String
        
        var paymentResponse: [String: Any] = [:]
        
        if result == "payment_successfull"{
            paymentResponse["status"] = "SUCCESS"
        }else {
            paymentResponse["status"] = "FAILED"
        }
        paymentResponse["payment_response"] = payment_response
        if let jsonString = customInstance.convertDictionaryToJson(dictionary: paymentResponse) {
            webView.evaluateJavaScript("javascript:sendPGPaymentResponse(\(jsonString));")
        }
    }
}
