//
//  DrawingScanningRect.swift
//  testQRScanner
//
//  Created by Ira Golubovich on 1/18/20.
//  Copyright © 2020 Ira Golubovich. All rights reserved.
//

import UIKit

class DrawingScanningRect {
    
    func drawRect(view: UIView, offsetY: CGFloat, offsetX: CGFloat, rectPath: UIBezierPath) -> CAShapeLayer {
        var rectPath = rectPath
        let path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height), cornerRadius: 0)
        let rectPathY = view.safeAreaInsets.top + offsetY
        rectPath = UIBezierPath(rect: CGRect(x: view.bounds.minX + offsetX, y: view.safeAreaInsets.top + offsetY, width: view.bounds.maxX - 2 * offsetX, height: view.bounds.maxY - rectPathY - offsetY))
        path.append(rectPath)
        
        let fillLayer = CAShapeLayer()
        fillLayer.path = path.cgPath
        fillLayer.fillRule = .evenOdd
        fillLayer.fillColor = view.backgroundColor?.cgColor
        fillLayer.opacity = 0.7
        
        return fillLayer
    }
}
