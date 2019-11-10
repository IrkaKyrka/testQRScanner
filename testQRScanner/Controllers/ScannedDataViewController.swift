//
//  ScaningResultViewController.swift
//  testQRScanner
//
//  Created by Ira Golubovich on 11/7/19.
//  Copyright © 2019 Ira Golubovich. All rights reserved.
//

import UIKit

class ScannedDataViewController: UIViewController {
    @IBOutlet weak var scannedImage: UIImageView!
    var url = ""
    private var activityIndicator = UIActivityIndicatorView()
    private let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))

    override func viewDidLoad() {
        loadImage(url: url)
    }
    
    private func loadImage(url: String) {
        activityIndicatorSetup()
        DispatchQueue.global().async { [weak self] in
        if let data = try? Data(contentsOf: URL(string: url)!) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.scannedImage.image = image
                        self?.stopActivityIndicator()
                    }
                }
            }
        }
    }
    
    private func activityIndicatorSetup() {
        effectView.frame = view.frame
        effectView.layer.masksToBounds = true
        
        activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.frame = CGRect(x: view.frame.midX - 100, y: view.frame.midY - 100, width: 200, height: 200)
        activityIndicator.startAnimating()
        
        effectView.contentView.addSubview(activityIndicator)
        view.addSubview(effectView)
    }
    
    private func stopActivityIndicator() {
        effectView.removeFromSuperview()
        activityIndicator.stopAnimating()
    }
}
