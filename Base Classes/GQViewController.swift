//
//  UIViewcontroller+Ext.swift
//  GQPaymentIOSSDK
//
//  Created by valentine on 01/02/24.
//

import UIKit

public class GQViewController: UIViewController {
    
    private weak var loader: UIActivityIndicatorView?
    
    public func showLoader() {
        DispatchQueue.main.async {
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
            
            // disable interaction
            self.view.isUserInteractionEnabled = false
        }
    }

    public func hideLoader() {
        DispatchQueue.main.async {
            self.loader?.stopAnimating()
            
            // enable interaction
            self.view.isUserInteractionEnabled = true
        }
    }
    
}
