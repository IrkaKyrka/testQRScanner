//
//  DrawingPreviewLayer.swift
//  testQRScanner
//
//  Created by Ira Golubovich on 1/26/20.
//  Copyright © 2020 Ira Golubovich. All rights reserved.
//

import UIKit
import AVFoundation

class DrawingPreviewLayer: AVCaptureVideoPreviewLayer {
     init(session: AVCaptureSession, view: UIView) {
        super.init()
        setupPreviewLayer(with: session, on: view)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupPreviewLayer(with session: AVCaptureSession, on view: UIView) {
//        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.session = session
        self.frame = view.layer.bounds
        self.videoGravity = .resizeAspectFill
    }
}
