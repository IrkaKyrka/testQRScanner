//
//  Canvas.swift
//  testQRScanner
//
//  Created by Ira Golubovich on 12/1/19.
//  Copyright © 2019 Ira Golubovich. All rights reserved.
//

import UIKit

class Canvas: UIView {
    private var strokeColor = UIColor.black
    private var strokeWidth: CGFloat = 1
    private var lines = [Line]()
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        lines.forEach { (line) in
            context.setStrokeColor(line.color.cgColor)
            context.setLineWidth(CGFloat(line.strokeWidth))
            context.setLineCap(.round)
            
            for (i, p) in line.points.enumerated() {
                i == 0 ? context.move(to: p) :  context.addLine(to: p)
            }
            context.strokePath()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        lines.append(Line(strokeWidth: strokeWidth, color: strokeColor, points: []))
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: nil) else { return }
        
        guard var lastLine = lines.popLast() else { return }
        lastLine.points.append(point)
        lines.append(lastLine)
        
        setNeedsDisplay()
    }
    
    func undo() {
        lines.removeLast()
        setNeedsDisplay()
    }
    
    func clear() {
        lines.removeAll()
        setNeedsDisplay()
    }
    
    func setStrokeColor(color: UIColor) {
        self.strokeColor = color
    }
    
    func setStrokeWidht(width: CGFloat) {
        self.strokeWidth = width
    }
    
    func setCanvasBackground() {
        self.backgroundColor = .clear
    }
}
