//
//  CustomScannerView.swift
//  testQRScanner
//
//  Created by Ira Golubovich on 1/28/20.
//  Copyright © 2020 Ira Golubovich. All rights reserved.
//

import UIKit
import AVFoundation

class CustomScannerView: UIView {
    private var previewLayer: DrawingPreviewLayer?
    private var boundingBox: DrawingBoundingBox!
    private var scanningRect: DrawingScanningRect!
    private var topLeftCorner: DrawingCorner!
    private var topRightCorner: DrawingCorner!
    private var bottomLeftCorner: DrawingCorner!
    private var bottomRightCorner: DrawingCorner!
    private var rectPath: UIBezierPath?
    private var descriptionTextLayer: CATextLayer?
    
    init(view: UIView, offsetX: CGFloat, offsetY: CGFloat, text: String, textHeight: CGFloat?) {
        super.init(frame: view.frame)
        setTextLayer(text: text)
        setupViews(view: view, offsetX: offsetX, offsetY: offsetY, text: text, textHeight: textHeight)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews(view: UIView, offsetX: CGFloat, offsetY: CGFloat, text: String, textHeight: CGFloat?) {
        let rectPath = UIBezierPath()
        previewLayer = DrawingPreviewLayer(session: CaptureSession.getCurrentCapterSession(), view: self)
        scanningRect = DrawingScanningRect(view: view, offsetY: offsetY, offsetX: offsetX, rectPath: rectPath)
        topLeftCorner = DrawingCorner(x: view.bounds.minX + offsetX, y: view.safeAreaInsets.top + offsetY, location: .topLeft, cornerSize: 6, cornerLineWidth: 20)
        topRightCorner = DrawingCorner(x: view.bounds.maxX - offsetX, y: view.safeAreaInsets.top + offsetY, location: .topRight, cornerSize: 6, cornerLineWidth: 20)
        bottomLeftCorner = DrawingCorner(x: view.bounds.minX + offsetX, y: view.bounds.maxY - offsetY, location: .bottomLeft, cornerSize: 6, cornerLineWidth: 20)
        bottomRightCorner = DrawingCorner(x: view.bounds.maxX - offsetX, y: view.bounds.maxY - offsetY, location: .bottomRight, cornerSize: 6, cornerLineWidth: 20)
        boundingBox = DrawingBoundingBox(width: 2, color: UIColor.green.cgColor)
        
        DispatchQueue.main.async {
            guard let previewLayer = self.previewLayer, let textHeight = textHeight, let textLayer = self.descriptionTextLayer else { return }
            
            textLayer.frame = CGRect(x: previewLayer.bounds.minX, y: view.safeAreaInsets.top + offsetY / 2 - (textHeight / 2), width: previewLayer.bounds.width , height: textHeight)
            
            view.layer.addSublayer(previewLayer)
            previewLayer.addSublayer(self.boundingBox)
            previewLayer.addSublayer(self.scanningRect)
            previewLayer.addSublayer(textLayer)
            previewLayer.addSublayer(self.topLeftCorner)
            previewLayer.addSublayer(self.topRightCorner)
            previewLayer.addSublayer(self.bottomLeftCorner)
            previewLayer.addSublayer(self.bottomRightCorner)
        }
    }
    
    func setTextLayer(text: String) {
        self.descriptionTextLayer = CATextLayer()
        guard let textLayer = self.descriptionTextLayer else { return }
        textLayer.foregroundColor = UIColor.white.cgColor
        textLayer.isWrapped = true
        textLayer.alignmentMode = .center
        textLayer.contentsScale = UIScreen.main.scale
        textLayer.font = UIFont.systemFont(ofSize: 5, weight: UIFont.Weight.light)
        textLayer.fontSize = 14
        textLayer.string = text
    }
    
    func getMetadataOutputRectConverted(rect: CGRect) -> CGRect? {
        return self.previewLayer?.metadataOutputRectConverted(fromLayerRect: rect)
    }
    
    func getTransformedMetadataObject(for object: AVMetadataObject) -> AVMetadataObject? {
        guard let transformedMetadataObject = self.previewLayer?.transformedMetadataObject(for: object) else { return nil }
        return transformedMetadataObject
    }
    
    func getScanningRect() -> CAShapeLayer {
        return scanningRect
    }
    
    func updateBoundingBox(points: [CGPoint]) {
        guard let firstPoint = points.first else {
            return
        }
        
        let path = UIBezierPath()
        path.move(to: firstPoint)
        
        var newPoints = points
        newPoints.removeFirst()
        newPoints.append(firstPoint)
        
        newPoints.forEach { path.addLine(to: $0) }
        
        boundingBox.path = path.cgPath
        boundingBox.isHidden = false
    }
    
    func hideBoundingBox(after: Double, completion: @escaping()->Void) {
        delay(1) { [weak self] in
            self?.boundingBox.isHidden = true
            completion()
        }
    }
    
    private func delay(_ delay: Double, closure: @escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + delay,
            execute: closure
        )
    }
}
