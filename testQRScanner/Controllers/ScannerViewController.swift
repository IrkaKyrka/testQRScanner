//
//  ScannerViewController.swift
//  testQRScanner
//
//  Created by Ira Golubovich on 10/15/19.
//  Copyright © 2019 Ira Golubovich. All rights reserved.
//

import UIKit
import AVFoundation

enum ConerLocation {
    case topRight, topLeft, bottomRight, bottomLeft
}

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
    
    let offsetY: CGFloat = 120
    let offsetX: CGFloat = 50
    let cornerSize: CGFloat = 20
    let cornerLineWidth: CGFloat = 6
    
    let descriptionTextLayer: CATextLayer = {
        let text = CATextLayer()
        text.string = "Поместите штрихкод в середине прямоугольника. Он будет отсканирован автоматически."
        text.foregroundColor = UIColor.white.cgColor
        text.isWrapped = true
        text.alignmentMode = CATextLayerAlignmentMode.center
        text.contentsScale = UIScreen.main.scale
        text.font = UIFont.systemFont(ofSize: 5, weight: UIFont.Weight.light)
        text.fontSize = 14

        return text
    }()
    
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
        let rectPathY = view.safeAreaInsets.top + offsetY
        rectPath = UIBezierPath(rect: CGRect(x: view.bounds.minX + offsetX, y: view.safeAreaInsets.top + offsetY, width: view.bounds.maxX - 2 * offsetX, height: view.bounds.maxY - rectPathY - offsetY))
        guard let rectPath = rectPath else { return CAShapeLayer() }
        path.append(rectPath)

        let fillLayer = CAShapeLayer()
        fillLayer.path = path.cgPath
        fillLayer.fillRule = .evenOdd
        fillLayer.fillColor = view.backgroundColor?.cgColor
        fillLayer.opacity = 0.7
        drawConer(x: view.bounds.minX + offsetX, y: view.safeAreaInsets.top + offsetY, location: .topLeft)
        drawConer(x: view.bounds.maxX - offsetX, y: view.safeAreaInsets.top + offsetY, location: .topRight)
        drawConer(x: view.bounds.minX + offsetX, y: view.bounds.maxY - offsetY, location: .bottomLeft)
        drawConer(x: view.bounds.maxX - offsetX, y: view.bounds.maxY - offsetY, location: .bottomRight)
        
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
                guard let self = self else { return }
                self.setupPreviewLayer()
                guard let previewLayer = self.previewLayer else { return }
                previewLayer.addSublayer(self.drawRectFofScanning())
                previewLayer.addSublayer(self.descriptionTextLayer)
                self.descriptionTextLayer.frame = CGRect(x: previewLayer.bounds.minX, y: self.view.safeAreaInsets.top, width: previewLayer.bounds.width , height: 100)
                self.drawBoundingBox()
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
    
    private func drawConer(x: CGFloat, y: CGFloat, location: ConerLocation) {
        conerLineFirst = CAShapeLayer()
        conerLineSecond = CAShapeLayer()
        
        if let conerLineFirst = conerLineFirst, let conerLineSecond = conerLineSecond {
            conerLineFirst.strokeColor = UIColor.white.cgColor
            conerLineFirst.lineWidth = cornerLineWidth
            conerLineFirst.fillColor = UIColor.clear.cgColor
            previewLayer?.addSublayer(conerLineFirst)
            conerLineSecond.strokeColor = UIColor.white.cgColor
            conerLineSecond.lineWidth = cornerLineWidth
            conerLineSecond.fillColor = UIColor.clear.cgColor
            previewLayer?.addSublayer(conerLineSecond)
        }
        let pathFirst = UIBezierPath()
        let pathSecond = UIBezierPath()
        
        switch location {
        case .topLeft:
            pathFirst.move(to: CGPoint(x: x + cornerLineWidth / 2, y: y))
            pathFirst.addLine(to: CGPoint(x: x + cornerLineWidth / 2, y: y + cornerSize))
            pathSecond.move(to: CGPoint(x: x, y: y + cornerLineWidth / 2))
            pathSecond.addLine(to: CGPoint(x: x + cornerSize, y: y + cornerLineWidth / 2))
        case .topRight:
            pathFirst.move(to: CGPoint(x: x - cornerLineWidth / 2, y: y))
            pathFirst.addLine(to: CGPoint(x: x - cornerLineWidth / 2, y: y + cornerSize))
            pathSecond.move(to: CGPoint(x: x, y: y + cornerLineWidth / 2))
            pathSecond.addLine(to: CGPoint(x: x - cornerSize, y: y + cornerLineWidth / 2))
        case .bottomLeft:
            pathFirst.move(to: CGPoint(x: x + cornerLineWidth / 2, y: y))
            pathFirst.addLine(to: CGPoint(x: x + cornerLineWidth / 2, y: y - cornerSize))
            pathSecond.move(to: CGPoint(x: x, y: y - cornerLineWidth / 2))
            pathSecond.addLine(to: CGPoint(x: x + cornerSize, y: y - cornerLineWidth / 2))
        case .bottomRight:
            pathFirst.move(to: CGPoint(x: x - cornerLineWidth / 2, y: y))
            pathFirst.addLine(to: CGPoint(x: x - cornerLineWidth / 2, y: y - cornerSize))
            pathSecond.move(to: CGPoint(x: x, y: y - cornerLineWidth / 2))
            pathSecond.addLine(to: CGPoint(x: x - cornerSize, y: y - cornerLineWidth / 2))
        }
        
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
