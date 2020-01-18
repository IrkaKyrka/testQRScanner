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
    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var metadataOutput: AVCaptureMetadataOutput?
    private var boundingBox: CAShapeLayer?
    private var scanningRect: DrawingScanningRect?
    private var rectPath: UIBezierPath?
    private var imageUrl: String?
    
    //MARK: - Constants
    private let offsetY: CGFloat = 120
    private let offsetX: CGFloat = 50
    private var corner: DrawingCorner?
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
        corner = DrawingCorner()
        scanningRect = DrawingScanningRect()
        NotificationCenter.default.addObserver(self, selector: #selector(setMetadataOutputRectOfInterest), name:NSNotification.Name.AVCaptureInputPortFormatDescriptionDidChange, object: nil)

        setupCaptureSession()
        setupMetadataOutput()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !captureSession.isRunning {
            captureSession.startRunning()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVCaptureInputPortFormatDescriptionDidChange, object: nil)
        
        super.viewDidDisappear(animated)
    }
    
    //MARK: - Private function
    @objc private func setMetadataOutputRectOfInterest() {
        guard let rectPath = rectPath, let metadataOutputRect = previewLayer?.metadataOutputRectConverted(fromLayerRect: rectPath.bounds) else { return }
        metadataOutput?.rectOfInterest = metadataOutputRect
    }
    
//    private func drawRectForScanning() -> CAShapeLayer {
//        let path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height), cornerRadius: 0)
//        let rectPathY = view.safeAreaInsets.top + offsetY
//        rectPath = UIBezierPath(rect: CGRect(x: view.bounds.minX + offsetX, y: view.safeAreaInsets.top + offsetY, width: view.bounds.maxX - 2 * offsetX, height: view.bounds.maxY - rectPathY - offsetY))
//        guard let rectPath = rectPath else { return CAShapeLayer() }
//        path.append(rectPath)
//
//        let fillLayer = CAShapeLayer()
//        fillLayer.path = path.cgPath
//        fillLayer.fillRule = .evenOdd
//        fillLayer.fillColor = view.backgroundColor?.cgColor
//        fillLayer.opacity = 0.7
//        drawCorner(x: view.bounds.minX + offsetX, y: view.safeAreaInsets.top + offsetY, location: .topLeft)
//        drawCorner(x: view.bounds.maxX - offsetX, y: view.safeAreaInsets.top + offsetY, location: .topRight)
//        drawCorner(x: view.bounds.minX + offsetX, y: view.bounds.maxY - offsetY, location: .bottomLeft)
//        drawCorner(x: view.bounds.maxX - offsetX, y: view.bounds.maxY - offsetY, location: .bottomRight)
        
//        return fillLayer
//    }
    
    private func setupCaptureSession() {
        let sessionQueue = DispatchQueue(label: "Capture Session Queue")
        
        sessionQueue.sync {
            captureSession = AVCaptureSession()
            captureSession.beginConfiguration()
            guard let viewCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
            let videoInput: AVCaptureDeviceInput
            
            do {
                videoInput = try AVCaptureDeviceInput(device: viewCaptureDevice)
            } catch let error as NSError {
                print("Initializer AVCaptureDeviceInput returnd error: \(error.localizedDescription)")
                return
            }
            
            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
            } else {
                showError()
                return
            }
            
            captureSession.commitConfiguration()
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.setupPreviewLayer()
                guard let previewLayer = self.previewLayer,
                    let topLeftCorner = self.corner?.drawCorner(x: self.view.bounds.minX + self.offsetX, y: self.view.safeAreaInsets.top + self.offsetY, location: .topLeft),
                    let topRightCorner = self.corner?.drawCorner(x: self.view.bounds.maxX - self.offsetX, y: self.view.safeAreaInsets.top + self.offsetY, location: .topRight),
                    let bottomLeftCorner = self.corner?.drawCorner(x: self.view.bounds.minX + self.offsetX, y: self.view.bounds.maxY - self.offsetY, location: .bottomLeft),
                    let bottomRightCorner = self.corner?.drawCorner(x: self.view.bounds.maxX - self.offsetX, y: self.view.bounds.maxY - self.offsetY, location: .bottomRight),
                    let scanningRect = self.scanningRect?.drawRect(view: self.view, offsetY: self.offsetY, offsetX: self.offsetX, rectPath: self.rectPath ?? UIBezierPath()) else { return }
                previewLayer.addSublayer(scanningRect)
                previewLayer.addSublayer(self.descriptionTextLayer)
                previewLayer.addSublayer(topLeftCorner)
                previewLayer.addSublayer(topRightCorner)
                previewLayer.addSublayer(bottomLeftCorner)
                previewLayer.addSublayer(bottomRightCorner)
                
                self.descriptionTextLayer.frame = CGRect(x: previewLayer.bounds.minX, y: self.view.safeAreaInsets.top + self.offsetY / 2 - (self.textHeight / 2), width: previewLayer.bounds.width , height: self.textHeight)
                self.drawBoundingBox()
            }
        }
    }
    
    private func setupMetadataOutput() {
        metadataOutput = AVCaptureMetadataOutput()
        guard let metadataOutput = metadataOutput else { return }
        
        if (captureSession?.canAddOutput(metadataOutput) ?? false) {
            captureSession?.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            showError()
        }
    }
    
    private func drawBoundingBox() {
        boundingBox = CAShapeLayer()

        if let boundingBox = boundingBox {
            boundingBox.strokeColor = UIColor.green.cgColor
            boundingBox.lineWidth = 2
            boundingBox.fillColor = UIColor.clear.cgColor
            previewLayer?.addSublayer(boundingBox)
        }
    }
    
    private func setupPreviewLayer() {
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.frame = view.layer.bounds
        previewLayer?.videoGravity = .resizeAspectFill
        guard  let previewLayer = previewLayer else { return }
        view.layer.addSublayer(previewLayer)
    }
    
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
        captureSession = nil
    }
    
    private func hideBoundingBox(after: Double) {
        var resetTimer: Timer?
        resetTimer?.invalidate()
        resetTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval() + after,
                                          repeats: false) {
                                            [weak self] (timer) in
                                            self?.boundingBox?.isHidden = true
                                            guard let imageUrl = self?.imageUrl else { return }
                                            self?.navigateTo(navigationItem: .scannedDataDetail(imageUrl: imageUrl), animated: true)
        }
    }
}

// MARK: - AVCaptureMetadataOutputObjectsDelegate
extension ScannerViewController {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        if metadataObjects.count == 0 {
            boundingBox?.frame = CGRect.zero
            return
        }
        
        captureSession.stopRunning()
        
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
