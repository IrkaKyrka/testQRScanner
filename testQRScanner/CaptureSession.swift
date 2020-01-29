//
//  CaptureSession.swift
//  testQRScanner
//
//  Created by Ira Golubovich on 1/26/20.
//  Copyright © 2020 Ira Golubovich. All rights reserved.
//

import Foundation
import AVFoundation

protocol CapterSessionDelegate: AVCaptureMetadataOutputObjectsDelegate {
    
}

class CaptureSession: NSObject, CapterSessionDelegate {
    static private var captureSession: AVCaptureSession!
    static private var metadataOutput: AVCaptureMetadataOutput?
    
    
    static func setupCaptureSession(onSuccess: ()->Void, onFailure: ()->Void) {
        let sessionQueue = DispatchQueue(label: "Capture Session Queue")
        
        sessionQueue.sync {
            CaptureSession.captureSession = AVCaptureSession()
            CaptureSession.captureSession.beginConfiguration()
            guard let viewCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
            let videoInput: AVCaptureDeviceInput
            
            do {
                videoInput = try AVCaptureDeviceInput(device: viewCaptureDevice)
            } catch let error as NSError {
                print("Initializer AVCaptureDeviceInput returnd error: \(error.localizedDescription)")
                return
            }
            
            if CaptureSession.captureSession.canAddInput(videoInput) {
                CaptureSession.captureSession.addInput(videoInput)
            } else {
                onFailure()
                return
            }
            
            CaptureSession.captureSession.commitConfiguration()
            onSuccess()
        }
    }
    
    static func setupMetadataOutput(delegate: CapterSessionDelegate, showError: ()->()) {
        CaptureSession.metadataOutput = AVCaptureMetadataOutput()
        guard let metadataOutput = CaptureSession.metadataOutput else { return }
           
        if (CaptureSession.captureSession?.canAddOutput(metadataOutput) ?? false) {
            CaptureSession.captureSession?.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(delegate, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
           } else {
            showError()
           }
       }
    
    static func stopSession() {
        CaptureSession.captureSession.stopRunning()
    }
    
    static func startSession() {
        CaptureSession.captureSession.startRunning()
    }
    
    static func isRunningSession() -> Bool {
        return CaptureSession.captureSession.isRunning
    }
    
    static func setRectOfInterest(rect: CGRect) {
         CaptureSession.metadataOutput?.rectOfInterest = rect
    }
    
    static func deinitCapterSession() {
        CaptureSession.captureSession = nil
    }
    
    static func getCurrentCapterSession() -> AVCaptureSession {
        return CaptureSession.captureSession
    }
}
