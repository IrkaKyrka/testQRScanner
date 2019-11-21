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
    private var conerLineFirst: CAShapeLayer?
    private var conerLineSecond: CAShapeLayer?
    private var rectPath: UIBezierPath?
    private let sessionQueue = DispatchQueue(label: "Capture Session Queue")
    private var imageUrl: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(setMetadataOutputRectOfInterest), name:NSNotification.Name.AVCaptureInputPortFormatDescriptionDidChange, object: nil)

        view.backgroundColor = .black
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
        super.viewDidDisappear(animated)
        
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }
    
    @objc func setMetadataOutputRectOfInterest() {
        guard let rectPath = rectPath, let metadataOutputRect = previewLayer?.metadataOutputRectConverted(fromLayerRect: rectPath.bounds) else { return }
        metadataOutput?.rectOfInterest = metadataOutputRect
    }
    
    private func drawRectFofScanning() -> CAShapeLayer {
        let path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height), cornerRadius: 0)
        rectPath = UIBezierPath(rect: CGRect(x: view.bounds.minX + 50, y: view.bounds.minY + 200, width: view.bounds.maxX - 100, height: view.bounds.maxY - 300))
        guard let rectPath = rectPath else { return CAShapeLayer() }
        path.append(rectPath)
//        path.usesEvenOddFillRule = true

        let fillLayer = CAShapeLayer()
        fillLayer.path = path.cgPath
        fillLayer.fillRule = .evenOdd
        fillLayer.fillColor = view.backgroundColor?.cgColor
        fillLayer.opacity = 0.7
        drawConer(x: view.bounds.minX + 53, y: view.bounds.minY + 203)
        
        return fillLayer
    }
    
    private func setupCaptureSession() {
        sessionQueue.sync {
            captureSession = AVCaptureSession()
            captureSession.beginConfiguration()
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
                showError()
                return
            }
            
            captureSession.commitConfiguration()
            
            DispatchQueue.main.async { [weak self] in
                self?.setupPreviewLayer()
                guard let previewLayer = self?.previewLayer else { return }
                previewLayer.addSublayer((self?.drawRectFofScanning())!)
                self?.drawBoundingBox()
            }
        }
    }
    
    private func setupMetadataOutput() {
        metadataOutput = AVCaptureMetadataOutput()
        guard let metadataOutput = metadataOutput else {return}
        
        if (captureSession?.canAddOutput(metadataOutput) ?? false) {
            captureSession?.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            showError()
            return
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
    
    
    func updateBoundingBox(_ points: [CGPoint]) {
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
    
    private func drawConer(x: CGFloat, y: CGFloat) {
        conerLineFirst = CAShapeLayer()
        conerLineSecond = CAShapeLayer()

        if let conerLineFirst = conerLineFirst, let conerLineSecond = conerLineSecond {
            conerLineFirst.strokeColor = UIColor.white.cgColor
            conerLineFirst.lineWidth = 6
            conerLineFirst.fillColor = UIColor.clear.cgColor
            previewLayer?.addSublayer(conerLineFirst)
            conerLineSecond.strokeColor = UIColor.white.cgColor
            conerLineSecond.lineWidth = 6
            conerLineSecond.fillColor = UIColor.clear.cgColor
            previewLayer?.addSublayer(conerLineSecond)
        }
        
        let pathFirst = UIBezierPath()
        guard let lineWidth = conerLineFirst?.lineWidth else { return }
        pathFirst.move(to: CGPoint(x: x, y: y + lineWidth / 2))
        pathFirst.addLine(to: CGPoint(x: x, y: y + 20 - lineWidth / 4))
        
        let pathSecond = UIBezierPath()
        pathSecond.move(to: CGPoint(x: x - lineWidth / 2, y: y))
        pathSecond.addLine(to: CGPoint(x: x + 20, y: y))
        conerLineFirst?.path = pathFirst.cgPath
        conerLineSecond?.path = pathSecond.cgPath

    }
    
    func showError() {
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

extension ScannerViewController {
     func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            
            if metadataObjects.count == 0 {
                boundingBox?.frame = CGRect.zero
                return
            }
            
            captureSession.stopRunning()
            
            if let metadataObject = metadataObjects.first {
                guard let transformedObject = previewLayer?.transformedMetadataObject(for: metadataObject) as? AVMetadataMachineReadableCodeObject else {
                    return }
                updateBoundingBox(transformedObject.corners)
                guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
                guard let stringValue = readableObject.stringValue else { return }
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                print(stringValue)
                imageUrl = stringValue
                hideBoundingBox(after: 1)
            }
        }
 }
