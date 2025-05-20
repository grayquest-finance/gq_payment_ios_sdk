//
//  WebDelegate.swift
//  GQPaymentIOSSDK
//
//  Created by Avinash Soni on 08/01/24.
//

import Foundation

@MainActor protocol WebDelegate {
    func sdSuccess(data: [String: Any]?)
    func sdCancel(data: [String: Any]?)
    func sdError(data: [String: Any]?)
}
