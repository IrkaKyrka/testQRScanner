//
//  DrawingBoundingBox.swift
//  testQRScanner
//
//  Created by Ira Golubovich on 1/19/20.
//  Copyright © 2020 Ira Golubovich. All rights reserved.
//

import UIKit

class DrawingBoundingBox: CAShapeLayer {
    
    init(width: CGFloat, color: CGColor) {
        super.init()
        drawBoundingBox(with: width, with: color)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func drawBoundingBox(with width: CGFloat, with color: CGColor) {
        self.strokeColor = color
        self.lineWidth = width
        self.fillColor = UIColor.clear.cgColor
    }
}
