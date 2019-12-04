//
//  BaseViewController.swift
//  testQRScanner
//
//  Created by Ira Golubovich on 12/3/19.
//  Copyright © 2019 Ira Golubovich. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    
    func activityIndicatorSetup(indicator: UIActivityIndicatorView, effectView: UIVisualEffectView) {
           effectView.frame = view.frame
           effectView.layer.masksToBounds = true
           indicator.frame = CGRect(x: view.frame.midX - 100, y: view.frame.midY - 100, width: 200, height: 200)
           indicator.startAnimating()
           
           effectView.contentView.addSubview(indicator)
           view.addSubview(effectView)
       }
    
    func stopActivityIndicator(indicator: UIActivityIndicatorView, effectView: UIVisualEffectView) {
           effectView.removeFromSuperview()
           indicator.stopAnimating()
       }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
}
