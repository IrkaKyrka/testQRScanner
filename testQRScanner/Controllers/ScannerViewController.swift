//
//  ScannerViewController.swift
//  testQRScanner
//
//  Created by Ira Golubovich on 10/15/19.
//  Copyright © 2019 Ira Golubovich. All rights reserved.
//

import UIKit
import AVFoundation


class ScannerViewController: UIViewController {
    //    private var captureSession: AVCaptureSession!
    private var previewLayer: DrawingPreviewLayer?
    //    private var metadataOutput: AVCaptureMetadataOutput?
    private var boundingBox: DrawingBoundingBox!
    private var scanningRect: DrawingScanningRect!
    private var rectPath: UIBezierPath?
    private var imageUrl: String?
    
    //MARK: - Constants
    private let offsetY: CGFloat = 120
    private let offsetX: CGFloat = 50
    private var topLeftCorner: DrawingCorner!
    private var topRightCorner: DrawingCorner!
    private var bottomLeftCorner: DrawingCorner!
    private var bottomRightCorner: DrawingCorner!
    private let textHeight: CGFloat = 50
    
    private let descriptionTextLayer: CATextLayer = {
        let text = CATextLayer()
        text.string = "Поместите штрихкод в середине прямоугольника. Он будет отсканирован автоматически."
        text.foregroundColor = UIColor.white.cgColor
        text.isWrapped = true
        text.alignmentMode = .center
        text.contentsScale = UIScreen.main.scale
        text.font = UIFont.systemFont(ofSize: 5, weight: UIFont.Weight.light)
        text.fontSize = 14
        
        return text
    }()
    
    //MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(setMetadataOutputRectOfInterest), name:NSNotification.Name.AVCaptureInputPortFormatDescriptionDidChange, object: nil)
        
        CaptureSession.setupCaptureSession() { success in
            if success {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    guard let previewLayer = self.previewLayer else { return }
                    self.view.layer.addSublayer(previewLayer)
                    previewLayer.addSublayer(self.scanningRect)
                    previewLayer.addSublayer(self.descriptionTextLayer)
                    previewLayer.addSublayer(self.topLeftCorner)
                    previewLayer.addSublayer(self.topRightCorner)
                    previewLayer.addSublayer(self.bottomLeftCorner)
                    previewLayer.addSublayer(self.bottomRightCorner)
                    
                    self.descriptionTextLayer.frame = CGRect(x: previewLayer.bounds.minX, y: self.view.safeAreaInsets.top + self.offsetY / 2 - (self.textHeight / 2), width: previewLayer.bounds.width , height: self.textHeight)
                    self.boundingBox = DrawingBoundingBox(width: 2, color: UIColor.green.cgColor)
                    previewLayer.addSublayer(self.boundingBox)
                }
            } else {
                showError()
            }
            
        }
        CaptureSession.setupMetadataOutput() {
            
        }
        
        previewLayer = DrawingPreviewLayer(session: CaptureSession.captureSession, view: self.view)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !CaptureSession.captureSession.isRunning {
            CaptureSession.captureSession.startRunning()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scanningRect = DrawingScanningRect(view: self.view, offsetY: self.offsetY, offsetX: self.offsetX, rectPath: self.rectPath ?? UIBezierPath())
        topLeftCorner = DrawingCorner(x: self.view.bounds.minX + self.offsetX, y: self.view.safeAreaInsets.top + self.offsetY, location: .topLeft, cornerSize: 6, cornerLineWidth: 20)
        topRightCorner = DrawingCorner(x: self.view.bounds.maxX - self.offsetX, y: self.view.safeAreaInsets.top + self.offsetY, location: .topRight, cornerSize: 6, cornerLineWidth: 20)
        bottomLeftCorner = DrawingCorner(x: self.view.bounds.minX + self.offsetX, y: self.view.bounds.maxY - self.offsetY, location: .bottomLeft, cornerSize: 6, cornerLineWidth: 20)
        bottomRightCorner = DrawingCorner(x: self.view.bounds.maxX - self.offsetX, y: self.view.bounds.maxY - self.offsetY, location: .bottomRight, cornerSize: 6, cornerLineWidth: 20)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if CaptureSession.captureSession.isRunning {
            CaptureSession.captureSession.stopRunning()
        }
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVCaptureInputPortFormatDescriptionDidChange, object: nil)
        
        super.viewDidDisappear(animated)
    }
    
    //MARK: - Private function
    @objc private func setMetadataOutputRectOfInterest() {
        guard let rectPath = rectPath, let metadataOutputRect = previewLayer?.metadataOutputRectConverted(fromLayerRect: rectPath.bounds) else { return }
        CaptureSession.metadataOutput?.rectOfInterest = metadataOutputRect
    }
    
    //    private func setupCaptureSession() {
    //        let sessionQueue = DispatchQueue(label: "Capture Session Queue")
    //
    //        sessionQueue.sync {
    //            captureSession = AVCaptureSession()
    //            captureSession.beginConfiguration()
    //            guard let viewCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
    //            let videoInput: AVCaptureDeviceInput
    //
    //            do {
    //                videoInput = try AVCaptureDeviceInput(device: viewCaptureDevice)
    //            } catch let error as NSError {
    //                print("Initializer AVCaptureDeviceInput returnd error: \(error.localizedDescription)")
    //                return
    //            }
    //
    //            if captureSession.canAddInput(videoInput) {
    //                captureSession.addInput(videoInput)
    //            } else {
    //                showError()
    //                return
    //            }
    //
    //            captureSession.commitConfiguration()
    //
    //            DispatchQueue.main.async { [weak self] in
    //                guard let self = self else { return }
    //                guard let previewLayer = self.previewLayer else { return }
    //                 self.view.layer.addSublayer(previewLayer)
    //                previewLayer.addSublayer(self.scanningRect)
    //                previewLayer.addSublayer(self.descriptionTextLayer)
    //                previewLayer.addSublayer(self.topLeftCorner)
    //                previewLayer.addSublayer(self.topRightCorner)
    //                previewLayer.addSublayer(self.bottomLeftCorner)
    //                previewLayer.addSublayer(self.bottomRightCorner)
    //
    //                self.descriptionTextLayer.frame = CGRect(x: previewLayer.bounds.minX, y: self.view.safeAreaInsets.top + self.offsetY / 2 - (self.textHeight / 2), width: previewLayer.bounds.width , height: self.textHeight)
    //                self.boundingBox = DrawingBoundingBox(width: 2, color: UIColor.green.cgColor)
    //                previewLayer.addSublayer(self.boundingBox)
    //            }
    //        }
    //    }
    
    //    private func setupMetadataOutput() {
    //        metadataOutput = AVCaptureMetadataOutput()
    //        guard let metadataOutput = metadataOutput else { return }
    //
    //        if (captureSession?.canAddOutput(metadataOutput) ?? false) {
    //            captureSession?.addOutput(metadataOutput)
    //            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
    //            metadataOutput.metadataObjectTypes = [.qr]
    //        } else {
    //            showError()
    //        }
    //    }
    
    private func updateBoundingBox(_ points: [CGPoint]) {
        guard let firstPoint = points.first else {
            return
        }
        
        let path = UIBezierPath()
        path.move(to: firstPoint)
        
        var newPoints = points
        newPoints.removeFirst()
        newPoints.append(firstPoint)
        
        newPoints.forEach { path.addLine(to: $0) }
        
        boundingBox?.path = path.cgPath
        boundingBox?.isHidden = false
    }
    
    private func showError() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Ok", style: .default))
        present(ac, animated: true)
        CaptureSession.captureSession = nil
    }
    
    private func hideBoundingBox(after: Double) {
        delay(1) { [weak self] in
            self?.boundingBox?.isHidden = true
            guard let imageUrl = self?.imageUrl else { return }
            self?.navigateTo(navigationItem: .scannedDataDetail(imageUrl: imageUrl), animated: true)
        }
    }
    
    private func delay(_ delay: Double, closure: @escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + delay,
            execute: closure
        )
    }
}

// MARK: - AVCaptureMetadataOutputObjectsDelegate
extension ScannerViewController {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        if metadataObjects.count == 0 {
            boundingBox?.frame = CGRect.zero
            return
        }
        
        CaptureSession.captureSession.stopRunning()
        
        guard let metadataObject = metadataObjects.first,
            let transformedObject = previewLayer?.transformedMetadataObject(for: metadataObject) as? AVMetadataMachineReadableCodeObject,
            let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
            let stringValue = readableObject.stringValue else { return }
        
        updateBoundingBox(transformedObject.corners)
        print(stringValue)
        imageUrl = stringValue
        hideBoundingBox(after: 1)
    }
}
