//
//  ScaningResultViewController.swift
//  testQRScanner
//
//  Created by Ira Golubovich on 11/7/19.
//  Copyright © 2019 Ira Golubovich. All rights reserved.
//

import UIKit

class ScannedDataViewController: UIViewController, UIScrollViewDelegate {
    @IBOutlet weak var scannedImage: UIImageView!
    var url = ""
    
    @IBOutlet weak var scrollView: UIScrollView!
    private let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var imageViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTrailingConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        loadImage(url: url)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateMinZoomScaleForSize(size: view.bounds.size)
    }
    
    @IBAction func rotateImageRight(_ sender: Any) {
        
        //       UIView.animate(withDuration: 1, animations: {
        self.scannedImage.image = self.scannedImage.image?.rotate(radians: .pi/2)
        //      })
    }
    
    @IBAction func rotateImageLeft(_ sender: Any) {
        self.scannedImage.image = self.scannedImage.image?.rotate(radians: -.pi/2)
    }
    
    private func loadImage(url: String) {
        activityIndicatorSetup()
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: URL(string: url)!) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        guard let self = self else { return }
                        self.scannedImage.image = image
                        self.updateConstraintsForSize(size: self.scannedImage.frame.size)
                        self.stopActivityIndicator()
                    }
                }
            }
        }
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
    
//    func crop(image: UIImage, cropRect: CGRect) -> UIImage? {
//        UIGraphicsBeginImageContextWithOptions(cropRect.size, false, image.scale)
//        let origin = CGPoint(x: cropRect.origin.x * CGFloat(-1), y: cropRect.origin.y * CGFloat(-1))
//            image.draw(at: origin)
//            let result = UIGraphicsGetImageFromCurrentImageContext()
//            UIGraphicsEndImageContext();
//
//        return result
//    }
    
    func updateMinZoomScaleForSize(size: CGSize) {
        let widthScale = size.width / scannedImage.bounds.width
        let heightScale = size.height / scannedImage.bounds.height
        let minScale = min(widthScale, heightScale)
        
        scrollView.minimumZoomScale = minScale
        scrollView.zoomScale = minScale
    }
    
    func updateConstraintsForSize(size: CGSize) {
        let yOffset = max(0, (size.height - scannedImage.frame.height) / 2)
        imageViewTopConstraint.constant = yOffset
        imageViewBottomConstraint.constant = yOffset
        
        let xOffset = max(0, (size.width - scannedImage.frame.width) / 2)
        imageViewLeadingConstraint.constant = xOffset
        imageViewTrailingConstraint.constant = xOffset
        
        view.layoutIfNeeded()
    }
}

extension ScannedDataViewController {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return scannedImage
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateConstraintsForSize(size: view.bounds.size)
    }
}
