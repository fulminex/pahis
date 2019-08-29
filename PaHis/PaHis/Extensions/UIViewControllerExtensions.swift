//
//  UIViewControllerExtensions.swift
//  ChatFirebase
//
//  Created by Angel Herrera Medina on 10/26/18.
//  Copyright © 2018 Angel Herrera Medina. All rights reserved.
//

import UIKit

extension UIViewController {
    class func displaySpinner(onView : UIView) -> UIView {
        let spinnerView = UIView()
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let activityIndicator = UIActivityIndicatorView.init(style: .whiteLarge)
        //        activityIndicator.color = UIColor(rgb: 0xF5391C)
        activityIndicator.startAnimating()
        spinnerView.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        spinnerView.translatesAutoresizingMaskIntoConstraints = false
        
        guard let window = UIApplication.shared.keyWindow else {
            onView.addSubview(spinnerView)
            spinnerView.topAnchor.constraint(equalTo: onView.topAnchor, constant: 0).isActive = true
            spinnerView.trailingAnchor.constraint(equalTo: onView.trailingAnchor, constant: 0).isActive = true
            spinnerView.leadingAnchor.constraint(equalTo: onView.leadingAnchor, constant: 0).isActive = true
            spinnerView.bottomAnchor.constraint(equalTo: onView.bottomAnchor, constant: 0).isActive = true
            activityIndicator.centerXAnchor.constraint(equalTo: spinnerView.centerXAnchor, constant: 0).isActive = true
            activityIndicator.centerYAnchor.constraint(equalTo: spinnerView.centerYAnchor, constant: 0).isActive = true
            return spinnerView
        }
        
        window.addSubview(spinnerView)
        spinnerView.topAnchor.constraint(equalTo: window.superview?.topAnchor ?? window.topAnchor, constant: 0).isActive = true
        spinnerView.trailingAnchor.constraint(equalTo: window.superview?.trailingAnchor ?? window.trailingAnchor, constant: 0).isActive = true
        spinnerView.leadingAnchor.constraint(equalTo: window.superview?.leadingAnchor ?? window.leadingAnchor, constant: 0).isActive = true
        spinnerView.bottomAnchor.constraint(equalTo: window.superview?.bottomAnchor ?? window.bottomAnchor, constant: 0).isActive = true
        activityIndicator.centerXAnchor.constraint(equalTo: spinnerView.centerXAnchor, constant: 0).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: spinnerView.centerYAnchor, constant: 0).isActive = true
        return spinnerView
    }
    
    class func removeSpinner(spinner :UIView) {
        DispatchQueue.main.async {
            spinner.removeFromSuperview()
        }
    }
}
