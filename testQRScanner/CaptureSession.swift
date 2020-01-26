//
//  CaptureSession.swift
//  testQRScanner
//
//  Created by Ira Golubovich on 1/26/20.
//  Copyright © 2020 Ira Golubovich. All rights reserved.
//

import Foundation
import AVFoundation

class CaptureSession: NSObject, AVCaptureMetadataOutputObjectsDelegate {
    static var captureSession: AVCaptureSession!
    static var metadataOutput: AVCaptureMetadataOutput?
    
    
    static func setupCaptureSession(success: (Bool)->()) {
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
                //                   showError()
                success(false)
                return
            }
            
            CaptureSession.captureSession.commitConfiguration()
            success(true)
        }
    }
    
    static func setupMetadataOutput(shoeError: ()->()) {
        CaptureSession.metadataOutput = AVCaptureMetadataOutput()
        guard let metadataOutput = CaptureSession.metadataOutput else { return }
           
        if (CaptureSession.captureSession?.canAddOutput(metadataOutput) ?? false) {
            CaptureSession.captureSession?.addOutput(metadataOutput)
//            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
           } else {
   //            showError()
            shoeError()
           }
       }
}
