//
//  APIService.swift
//  GQPaymentIOSSDK
//
//  Created by Avinash Soni on 08/01/24.
//

import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case badURLResponse(String)
    case decodingError
    case somethingWentWrong(String)
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .badURLResponse(let message):
            return message
        case .decodingError:
            return "Decoding Error"
        case .somethingWentWrong(let message):
            return message
        }
    }
}

class APIService {
    
    @MainActor static func makeAPICall() async throws -> [String: Any]? {
        let environment = Environment.shared
        
        guard let url = URL(string:environment.baseURL() + Environment.customerAPI) else { throw NetworkError.invalidURL }
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
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Check for HTTP response
            guard let httpResponse = response as? HTTPURLResponse, (200 ... 299) ~= httpResponse.statusCode else {
                if let errorJSON = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let errorMessage = errorJSON["message"] as? String {
                    throw NetworkError.badURLResponse(errorMessage)
                }
                throw NetworkError.somethingWentWrong("Something went wrong")
            }
            
            let responseObject = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            return responseObject
            
        } catch is DecodingError {
            throw NetworkError.decodingError
        } catch {
            throw NetworkError.somethingWentWrong(error.localizedDescription)
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
