//
//  UIViewcontroller+Ext.swift
//  GQPaymentIOSSDK
//
//  Created by valentine on 01/02/24.
//

import UIKit

//MARK: A Base Class for GQPaymentSDK Viewcontrollers
public class GQViewController: UIViewController {
    
    //MARK: Parameter - UI Loader
    private weak var loader: UIActivityIndicatorView?
    
    //MARK: Function to display loader
    public func showLoader() {
        DispatchQueue.main.async {
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
            
            // disable interaction
            self.view.isUserInteractionEnabled = false
        }
    }

    //MARK: Function to hide loader
    public func hideLoader() {
        DispatchQueue.main.async {
            self.loader?.stopAnimating()
            
            // enable interaction
            self.view.isUserInteractionEnabled = true
        }
    }
    
}
