//
//  DrawingCorner.swift
//  testQRScanner
//
//  Created by Ira Golubovich on 1/18/20.
//  Copyright © 2020 Ira Golubovich. All rights reserved.
//

import UIKit
import AVFoundation

class DrawingCorner {
    private let cornerSize: CGFloat = 20
    private let cornerLineWidth: CGFloat = 6
    
    func drawCorner(x: CGFloat, y: CGFloat, location: CornerLocation) -> CAShapeLayer {
        let cornerLine = CAShapeLayer()
        let path = UIBezierPath()
        
        cornerLine.strokeColor = UIColor.white.cgColor
        cornerLine.lineWidth = cornerLineWidth
        cornerLine.fillColor = UIColor.white.cgColor
//        layer?.addSublayer(cornerLine)
        
        switch location {
        case .topLeft:
            path.move(to: CGPoint(x: x + cornerLineWidth / 2, y: y + cornerSize))
            path.addLine(to: CGPoint(x: x + cornerLineWidth / 2, y: y))
            path.close()
            path.move(to: CGPoint(x: x, y: y + cornerLineWidth / 2))
            path.addLine(to: CGPoint(x: x + cornerSize, y: y + cornerLineWidth / 2))
            path.close()
        case .topRight:
            path.move(to: CGPoint(x: x - cornerLineWidth / 2, y: y + cornerSize))
            path.addLine(to: CGPoint(x: x - cornerLineWidth / 2, y: y))
            path.close()
            path.move(to: CGPoint(x: x, y: y + cornerLineWidth / 2))
            path.addLine(to: CGPoint(x: x - cornerSize, y: y + cornerLineWidth / 2))
            path.close()
        case .bottomLeft:
            path.move(to: CGPoint(x: x + cornerLineWidth / 2, y: y - cornerSize))
            path.addLine(to: CGPoint(x: x + cornerLineWidth / 2, y: y))
            path.close()
            path.move(to: CGPoint(x: x, y: y - cornerLineWidth / 2))
            path.addLine(to: CGPoint(x: x + cornerSize, y: y - cornerLineWidth / 2))
            path.close()
        case .bottomRight:
            path.move(to: CGPoint(x: x - cornerLineWidth / 2, y: y - cornerSize))
            
            path.addLine(to: CGPoint(x: x - cornerLineWidth / 2, y: y))
            path.close()
            path.move(to: CGPoint(x: x, y: y - cornerLineWidth / 2))
            path.addLine(to: CGPoint(x: x - cornerSize, y: y - cornerLineWidth / 2))
            path.close()
            
        }
        
        cornerLine.path = path.cgPath
        
        return cornerLine
    }
}
