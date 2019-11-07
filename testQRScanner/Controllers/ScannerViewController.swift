//
//  ScannerViewController.swift
//  testQRScanner
//
//  Created by Ira Golubovich on 10/15/19.
//  Copyright © 2019 Ira Golubovich. All rights reserved.
//

import UIKit
import AVFoundation

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    private var maskLayer = CALayer()
    
    private let photoOutput = AVCapturePhotoOutput()
    private var isCapturing = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        captureSession.addOutput(photoOutput)
        
        view.backgroundColor = .black
        captureSession = AVCaptureSession()
        
        guard let viewCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: viewCaptureDevice)
        } catch {
            return
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession?.canAddOutput(metadataOutput) ?? false) {
            captureSession?.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.frame = view.layer.bounds
        previewLayer?.videoGravity = .resizeAspectFill
        guard  let previewLayer = previewLayer else { return }
        view.layer.addSublayer(previewLayer)

        let path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height), cornerRadius: 0)
        let rectPath = UIBezierPath(rect: CGRect(x: view.bounds.minX + 50, y: view.bounds.minY + 100, width: view.bounds.maxX - 100, height: view.bounds.maxY - 200))
        path.append(rectPath)
        path.usesEvenOddFillRule = true

        let fillLayer = CAShapeLayer()
        fillLayer.path = path.cgPath
        fillLayer.fillRule = .evenOdd
        fillLayer.fillColor = view.backgroundColor?.cgColor
        fillLayer.opacity = 0.7
        previewLayer.addSublayer(fillLayer)
 
        qrCodeFrameView = UIView()

        if let qrCodeFrameView = qrCodeFrameView {
            qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
            qrCodeFrameView.layer.borderWidth = 2
            view.addSubview(qrCodeFrameView)
            view.bringSubviewToFront(qrCodeFrameView)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !captureSession.isRunning {
            captureSession.startRunning()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }
    
    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Ok", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            //            messageLabel.text = "No QR code is detected"
            return
        }
        
        captureSession.stopRunning()
        
        if let metadataObject = metadataObjects.first {
            if metadataObject.type == AVMetadataObject.ObjectType.qr {
                let barCodeObject = previewLayer?.transformedMetadataObject(for: metadataObject)
                qrCodeFrameView?.frame = barCodeObject!.bounds
            }
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue)
        }
        
        let photoSettings = AVCapturePhotoSettings()
        if !isCapturing {
            isCapturing = true
            photoOutput.capturePhoto(with: photoSettings, delegate: self)
        }
    }
    
    func found(code: String) {
        print(code)
        //     captureSession.startRunning()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}

extension ScannerViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        isCapturing = false
        guard let imageData = photo.fileDataRepresentation() else {
            print("Error while generating image from photo capture data.");
            return
        }
        guard let qrImage = UIImage(data: imageData) else {
            print("Unable to generate UIImage from image data.");
            return
        }
//        testImageView.image = qrImage
     }
}
