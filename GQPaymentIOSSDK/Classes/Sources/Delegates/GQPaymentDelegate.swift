//
//  GQPaymentDelegate.swift
//  GQPaymentIOSSDK
//
//  Created by Avinash Soni on 08/01/24.
//

import Foundation

//MARK: The Protocol which must contain these events for Success, Failure and Cancel.
// This Protocol will be used as a delegate which must be assigned toa class to receive the SDK events
public protocol GQPaymentDelegate
{
    func gqSuccessResponse(data: [String: Any]?)
    
    func gqFailureResponse(data: [String: Any]?)
    
    func gqCancelResponse(data: [String: Any]?)
}
