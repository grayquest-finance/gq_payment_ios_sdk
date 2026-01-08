//
//  WebDelegate.swift
//  GQPaymentIOSSDK
//
//  Created by Avinash Soni on 08/01/24.
//

import Foundation

//MARK: The Protocol for Success, Failure and Cancel events which will be used internally in the SDK.
protocol WebDelegate{
    func sdSuccess(data: [String: Any]?)
    func sdCancel(data: [String: Any]?)
    func sdError(data: [String: Any]?)
}
