//
//  ScaningResultViewController.swift
//  testQRScanner
//
//  Created by Ira Golubovich on 11/7/19.
//  Copyright © 2019 Ira Golubovich. All rights reserved.
//

import UIKit

class ScannedDataViewController: BaseViewController, UIScrollViewDelegate {
    var urlString: String?
    private var scannedImageView = UIImageView()
    private let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    private let activityIndicator = UIActivityIndicatorView()
    
    //MARK: - Outlets
    @IBOutlet weak var scrollView: UIScrollView!
    
   //MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadImage(urlString: urlString ?? "")
        
        scrollView.delegate = self
        scannedImageView.frame = CGRect(x: 0, y: 0, width: scrollView.bounds.width, height: scrollView.bounds.height)
        scannedImageView.isUserInteractionEnabled = true
        scrollView.addSubview(scannedImageView)
    }
    
    //MARK: - Actions
    @IBAction func rotateImageRight(_ sender: Any) {
        //TODO: animation
        self.scannedImageView.image = self.scannedImageView.image?.rotate(radians: .pi/2)
    }
    
    @IBAction func rotateImageLeft(_ sender: Any) {
        //TODO: animation
        self.scannedImageView.image = self.scannedImageView.image?.rotate(radians: -.pi/2)
    }
    
    @IBAction func cropAndSaveImage(_ sender: Any) {
        UIGraphicsBeginImageContextWithOptions(scrollView.bounds.size, true, UIScreen.main.scale)
        let offset = scrollView.contentOffset
        
        UIGraphicsGetCurrentContext()?.translateBy(x: -offset.x, y: -offset.y)
        scrollView.layer.render(in: UIGraphicsGetCurrentContext()!)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        guard let imageForSave = image else { return }
        navigateTo(navigationItem: .drawing(image: imageForSave), animated: true)
    }
    
    //MARK: - Private functions
    private func loadImage(urlString: String) {
        activityIndicatorSetup(indicator: activityIndicator, effectView: effectView)
        DispatchQueue.global().async { [weak self] in
            guard let url = URL(string: urlString), let data = try? Data(contentsOf: url), let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.setImage(image: image)
                self.stopActivityIndicator(indicator: self.activityIndicator, effectView: self.effectView)
            }
        }
    }
    
    private func setImage(image: UIImage) {
        scannedImageView.image = image
        scannedImageView.contentMode = .center
        scannedImageView.frame = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        
        scrollView.contentSize = image.size
        
        let scrollViewFrame = scrollView.frame
        let scaleWidth = scrollViewFrame.size.width / scrollView.contentSize.width
        let scaleHight = scrollViewFrame.size.height / scrollView.contentSize.height
        let minScale = min(scaleWidth, scaleHight)
        
        scrollView.minimumZoomScale = minScale
        scrollView.maximumZoomScale = 1
        scrollView.zoomScale = minScale
        
        centerScrollViewContents()
    }
    
    private func centerScrollViewContents() {
        let boundsSize = scrollView.bounds.size
        var contentFrame = scannedImageView.frame
        
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
        
        scannedImageView.frame = contentFrame
    }
}

//MARK: - UIScrollViewDelegate
extension ScannedDataViewController {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return scannedImageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerScrollViewContents()
    }
}
