//
//  APIService.swift
//  GQPaymentIOSSDK
//
//  Created by Avinash Soni on 08/01/24.
//

import Foundation

class APIService {
    
    static func performCreateCustomer() async throws -> [String: Any]? {
        let environment = Environment.shared
        
        guard let url = URL(string:environment.baseURL() + Environment.customerAPI) else { return nil }
        
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
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Check for HTTP response
        guard let httpResponse = response as? HTTPURLResponse, (200 ... 299) ~= httpResponse.statusCode else {
            // Attempt to parse error response JSON
            let errorJSON = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            let errorMessage = errorJSON?["message"] as? String
            throw GQError.somethingWentWrong(errorMessage)
        }
        
        do {
            let responseObject = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            return responseObject
        } catch {
            throw GQError.decodeError(error.localizedDescription)
        }
        
    }
    
    static func fetchSessionCode(token: String) async throws -> [String: Any]? {
        let environment = Environment.shared

        guard let url = URL(string: environment.baseURL() + Environment.sessionCodeAPI) else { return nil }

        // Prepare request
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")


        // Make API request
        let (data, response) = try await URLSession.shared.data(for: request)

        // Check for HTTP response
        guard let httpResponse = response as? HTTPURLResponse, (200 ... 299) ~= httpResponse.statusCode else {
            // Attempt to parse error response JSON
            let errorJSON = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            let errorMessage = errorJSON?["message"] as? String
            throw GQError.somethingWentWrong(errorMessage)
        }

        do {
            let responseObject = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            return responseObject
        } catch {
            throw GQError.decodeError(error.localizedDescription)
        }
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
