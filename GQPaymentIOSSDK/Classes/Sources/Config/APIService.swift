//
//  APIService.swift
//  GQPaymentIOSSDK
//
//  Created by Avinash Soni on 08/01/24.
//

import Foundation
class APIService{
    static func makeAPICall(completion: @escaping ([String: Any]?, String?) -> Void) {
        let environment = Environment.shared
        
        let url = URL(string:environment.baseURL()+Environment.customerAPI)!
        // Prepare request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("\(environment.gqApiKey)", forHTTPHeaderField: "GQ-API-Key")
        request.setValue("Basic \(environment.abase)", forHTTPHeaderField: "Authorization")
        
        let parameters: [String: Any] = [
            "customer_mobile": "\(environment.customerNumber)",
        ]
        request.httpBody = parameters.percentEncoded()
        
        // Make API request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Check for fundamental networking error
            guard error == nil else {
                return
            }
            
            // Check for HTTP response
            guard let httpResponse = response as? HTTPURLResponse else {
//                print( "Unexpected response format")
                return
            }
            
            // Check for HTTP errors
            guard (200 ... 299) ~= httpResponse.statusCode else {
                if let data = data {
                    do {
                        // Attempt to parse error response JSON
                        if let errorJSON = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                           let errorMessage = errorJSON["message"] as? String {
//                            print("errorCode: \(httpResponse.statusCode)")
//                            print("errorMessage: \(errorMessage)")
                            completion(nil, errorMessage)
                        } else {
//                            print("Unable to parse error response as JSON")
                        }
                    } catch {
//                        print("Error parsing error JSON: \(error)")
                    }
                } else {
//                    print("No data in the error response")
                }
                return
            }
            
            // Process the successful response
            guard let responseData = data else {
//                print("No data in the response")
                return
            }
            
            do {
                let responseObject = try JSONSerialization.jsonObject(with: responseData) as? [String: Any]
                completion(responseObject, nil)
            } catch {
//                print("Error parsing response JSON: \(error)")
            }
        }
        
        
        task.resume()
    }
}

extension Dictionary {
    func percentEncoded() -> Data? {
        map { key, value in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedValue
        }
        .joined(separator: "&")
        .data(using: .utf8)
    }
}

extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        
        var allowed: CharacterSet = .urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}
