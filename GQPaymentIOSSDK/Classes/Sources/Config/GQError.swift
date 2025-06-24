//
//  GQError.swift
//  Pods
//
//  Created by Velentine Miranda on 20/06/25.
//

import Foundation

enum GQError: Error, LocalizedError {
    case noInternet
    case noData
    case somethingWentWrong(String?)
    case decodeError(String)
    case validationError(String)
    
    static let somethingWentWrong = "Something went wrong"
    
    var errorDescription: String? {
        switch self {
        case .noInternet:
            return "No internet connection"
        case .noData:
            return "No data available"
        case .somethingWentWrong(let message):
            return message ?? GQError.somethingWentWrong
        case .decodeError:
//            return "Decoding error: \(message)"
            return GQError.somethingWentWrong
        case .validationError(let message):
            return message
        }
    }
}
