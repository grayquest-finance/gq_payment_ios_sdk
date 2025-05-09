//
//  GQPaymentDelegate.swift
//  GQPaymentIOSSDK
//
//  Created by Avinash Soni on 08/01/24.
//

import Foundation

@MainActor public protocol GQPaymentDelegate
{
    func gqSuccessResponse(data: [String: Any]?)
    
    func gqFailureResponse(data: [String: Any]?)
    
    func gqCancelResponse(data: [String: Any]?)
}
