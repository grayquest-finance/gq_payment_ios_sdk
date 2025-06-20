//
//  GQError.swift
//  Pods
//
//  Created by Velentine Miranda on 20/06/25.
//

import Foundation

enum GQError: Error {
    case noInternet
    case noData
    case somethingWentWrong(String?)
    case decodeError(String)
    
    static let somethingWentWrong = "Something went wrong"
    
    var message: String {
        switch self {
        case .noInternet:
            return "No internet connection"
        case .noData:
            return "No data available"
        case .somethingWentWrong(let message):
            return message ?? GQError.somethingWentWrong
        case .decodeError(let message):
//            return "Decoding error: \(message)"
            return GQError.somethingWentWrong
        }
    }
}
