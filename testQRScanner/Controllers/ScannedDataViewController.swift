//
//  ScaningResultViewController.swift
//  testQRScanner
//
//  Created by Ira Golubovich on 11/7/19.
//  Copyright © 2019 Ira Golubovich. All rights reserved.
//

import UIKit

class ScannedDataViewController: UIViewController, UIScrollViewDelegate {
    var url = ""
    private var scannedImage = UIImageView()
    private let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        loadImage(url: url)
        
        scrollView.delegate = self
        scannedImage.frame = CGRect(x: 0, y: 0, width: scrollView.bounds.width, height: scrollView.bounds.height)
        scannedImage.isUserInteractionEnabled = true
        scrollView.addSubview(scannedImage)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    @IBAction func rotateImageRight(_ sender: Any) {
        //       UIView.animate(withDuration: 1, animations: {
        self.scannedImage.image = self.scannedImage.image?.rotate(radians: .pi/2)
        //      })
    }
    
    @IBAction func rotateImageLeft(_ sender: Any) {
        self.scannedImage.image = self.scannedImage.image?.rotate(radians: -.pi/2)
    }
    
    @IBAction func cropImage(_ sender: Any) {
        UIGraphicsBeginImageContextWithOptions(scrollView.bounds.size, true, UIScreen.main.scale)
        let offset = scrollView.contentOffset
        
        UIGraphicsGetCurrentContext()?.translateBy(x: -offset.x, y: -offset.y)
        scrollView.layer.render(in: UIGraphicsGetCurrentContext()!)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        guard let imageForSave = image else { return }
        UIImageWriteToSavedPhotosAlbum(imageForSave, nil, nil, nil)
        showAlert()
    }
    
    private func loadImage(url: String) {
        activityIndicatorSetup()
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: URL(string: url)!) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        guard let self = self else { return }
                        self.setImage(image: image)
                        self.stopActivityIndicator()
                    }
                }
            }
        }
    }
    
    private func showAlert() {
        let alert = UIAlertController(title: "Image saved", message: "Your image has  been saved to your camera roll", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
    
    private func setImage(image: UIImage) {
        scannedImage.image = image
        scannedImage.contentMode = .center
        scannedImage.frame = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        
        scrollView.contentSize = image.size
        
        let scrollViewFrame = scrollView.frame
        let scaleWidth = scrollViewFrame.size.width / scrollView.contentSize.width
        let scaleHight = scrollViewFrame.size.height / scrollView.contentSize.height
        let minScale = min(scaleWidth, scaleHight)
        
        scrollView.minimumZoomScale = minScale
        scrollView.maximumZoomScale = 1
        scrollView.zoomScale = minScale
        
        centerScrollViewComtents()
    }
    
    private func centerScrollViewComtents() {
        let boundsSize = scrollView.bounds.size
        var contentFrame = scannedImage.frame
        
        if contentFrame.size.width < boundsSize.width {
            contentFrame.origin.x = (boundsSize.width - contentFrame.size.width) / 2
        } else {
            contentFrame.origin.x = 0
        }
        
        if contentFrame.size.height < boundsSize.height {
            contentFrame.origin.y = (boundsSize.height - contentFrame.height) / 2
        } else {
            contentFrame.origin.y = 0
        }
        
        scannedImage.frame = contentFrame
    }
    
    private func activityIndicatorSetup() {
           effectView.frame = view.frame
           effectView.layer.masksToBounds = true
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

extension ScannedDataViewController {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return scannedImage
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerScrollViewComtents()
    }
}
