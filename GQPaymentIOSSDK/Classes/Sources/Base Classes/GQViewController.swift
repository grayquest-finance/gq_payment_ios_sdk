//
//  UIViewcontroller+Ext.swift
//  GQPaymentIOSSDK
//
//  Created by valentine on 01/02/24.
//

import UIKit

@MainActor public class GQViewController: UIViewController {
    
    private weak var loader: UIActivityIndicatorView?
    
    public func showLoader() {
        if let loader = self.loader {
            loader.startAnimating()
            loader.isHidden = false
        } else {
            let activityIndicator = UIActivityIndicatorView()
            activityIndicator.hidesWhenStopped = true
            activityIndicator.color = .black
            activityIndicator.backgroundColor = .black.withAlphaComponent(0.3)
            self.view.addSubview(activityIndicator)
            
            //Adding Constraints
            activityIndicator.translatesAutoresizingMaskIntoConstraints = false
            activityIndicator.center = self.view.center
            activityIndicator.heightAnchor.constraint(equalToConstant: 40).isActive = true
            activityIndicator.widthAnchor.constraint(equalToConstant: 40).isActive = true
            activityIndicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
            activityIndicator.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
            
            activityIndicator.startAnimating()
            self.view.addSubview(activityIndicator)
            self.loader = activityIndicator
        }
        
        self.view.isUserInteractionEnabled = false
    }
    
    public func hideLoader() {
        self.loader?.stopAnimating()
        self.view.isUserInteractionEnabled = true
    }
    
}
