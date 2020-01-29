//
//  ScannerViewController.swift
//  testQRScanner
//
//  Created by Ira Golubovich on 10/15/19.
//  Copyright © 2019 Ira Golubovich. All rights reserved.
//

import UIKit
import AVFoundation


class ScannerViewController: UIViewController, CapterSessionDelegate {
   // private var rectPath: UIBezierPath?
    private var imageUrl: String?
    
    //MARK: - Constants
    private let offsetY: CGFloat = 120
    private let offsetX: CGFloat = 50
    private var scannerView: CustomScannerView?
    private let textHeight: CGFloat = 50
    private let scanningDescription = "Поместите штрихкод в середине прямоугольника. Он будет отсканирован автоматически."

    //MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(setMetadataOutputRectOfInterest), name:NSNotification.Name.AVCaptureInputPortFormatDescriptionDidChange, object: nil)
        
        CaptureSession.setupCaptureSession(onSuccess: {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.scannerView = CustomScannerView(view: self.view, offsetX: self.offsetX, offsetY: self.offsetY, text: self.scanningDescription, textHeight: self.textHeight)
                self.view.addSubview(self.scannerView ?? UIView())
            }
        }, onFailure: {
            showError(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.")
        })
        
        CaptureSession.setupMetadataOutput(delegate: self) {
            showError(title: "Scanning not supported", message: "Something went wrong.")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !CaptureSession.isRunningSession() {
            CaptureSession.startSession()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if CaptureSession.isRunningSession() {
            CaptureSession.stopSession()
        }
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVCaptureInputPortFormatDescriptionDidChange, object: nil)
        
        super.viewDidDisappear(animated)
    }
    
    //MARK: - Private function
    @objc private func setMetadataOutputRectOfInterest() {
        let scannigRect = CGRect(x: offsetX, y: offsetY + self.view.safeAreaInsets.top, width: self.view.frame.width - offsetX * 2, height: self.view.frame.height - offsetY * 2 - self.view.safeAreaInsets.top)
        guard let metadataOutputRect = scannerView?.getMetadataOutputRectConverted(rect: scannigRect) else { return }
        CaptureSession.setRectOfInterest(rect: metadataOutputRect)
    }
    
    private func showError(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Ok", style: .default))
        present(ac, animated: true)
        CaptureSession.deinitCapterSession()
    }
}

// MARK: - AVCaptureMetadataOutputObjectsDelegate
extension ScannerViewController {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
     
        CaptureSession.stopSession()
        
        guard let metadataObject = metadataObjects.first,
            let transformedObject = scannerView?.getTransformedMetadataObject(for: metadataObject) as? AVMetadataMachineReadableCodeObject,
            let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
            let stringValue = readableObject.stringValue else { return }
        
        scannerView?.updateBoundingBox(points: transformedObject.corners)
        print(stringValue)
        imageUrl = stringValue
        scannerView?.hideBoundingBox(after: 1) { [weak self] in
            guard let imageUrl = self?.imageUrl else { return }
            self?.navigateTo(navigationItem: .scannedDataDetail(imageUrl: imageUrl), animated: true)
        }
    }
}
