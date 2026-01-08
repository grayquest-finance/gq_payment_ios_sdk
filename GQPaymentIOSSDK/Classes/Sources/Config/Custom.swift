//
//  Common.swift
//  GQPaymentIOSSDK
//
//  Created by Avinash Soni on 08/01/24.
//

import Foundation

//MARK: A Class for validation and encoding logic
class Custom {
    
    //MARK: Function for converting dictionary to JSON
    //         - parameters:
    //                dictionary - A dictionary of type [String: Any]
    //         - returns:
    //                A String which contains the dictionary in utf8 format
    public func convertDictionaryToJson(dictionary: [String: Any]) -> String? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            } else {
                return nil
            }
        } catch {
            return nil
        }
    }
    
    //MARK: Function for encoding String to Base64 Encoded
    //         - parameters:
    //                inputString - A String to be converted into base64
    //         - returns:
    //                A String which is in base64 format
    func encodeStringToBase64(_ inputString: String) -> String? {
        if let inputData = inputString.data(using: .utf8) {
            return inputData.base64EncodedString()
        }
        return nil
    }
    
    //MARK: Function to convert dictionary to String
    //         - parameters:
    //                dictionary - A dictionary of type [String: Any]
    //         - returns:
    //                A String which contains the dictionary in utf8 format
    func outputJSON(dictionary: [String: Any]) -> String? {
        if let jsonData = try? JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            return jsonString
        } else {
            return nil
        }
    }
    
    //MARK: Function to validate the environment
    //         - parameters:
    //                value - the environment in String format
    //         - returns:
    //                A Bool which describes if the environment is valid or not
    func containsAnyValidEnvironment(_ value: String) -> Bool {
        let validEnvironments = ["test", "stage", "preprod", "live"]
        return validEnvironments.contains(value.lowercased())
    }
    
    //MARK: Function to validate the mobile number using regex
    //         - parameters:
    //                value - the mobile number in String format
    //         - returns:
    //                A Bool which describes if the mobile number is valid or not
    func validate(value: String) -> Bool {
        let phoneRegex = #"^\d{10}$"#
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        let result = phoneTest.evaluate(with: value)
        return result
    }
}

extension Custom {
    //MARK: Function to validate deep linking schemes
    //         - parameters:
    //                url - the deep linking URL
    //         - returns:
    //                A Bool which describes if the URL is for deep linking or not
    static func validateDeepLinkingScheme(with url: URL?) -> Bool {
        guard let url, let scheme = url.scheme else { return false }
        
        let excludedSchemes: Set<String> = ["http", "https", "about"]
        
        return !(excludedSchemes.contains(scheme))
        
    }
}
