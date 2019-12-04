//
//  DrawingViewController.swift
//  testQRScanner
//
//  Created by Ira Golubovich on 12/1/19.
//  Copyright © 2019 Ira Golubovich. All rights reserved.
//

import UIKit

class DrawingViewController: UIViewController {
    var image: UIImage?
    private let canvas = Canvas()
            
    //MARK: - Outlets
    @IBOutlet weak var drawingImageView: UIImageView!
    
    //MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.drawingImageView.image = image
        
        canvas.frame = drawingImageView.bounds
        canvas.setCanvasBackground()
        drawingImageView.addSubview(canvas)
    }
    
    //MARK: - Actions
    @IBAction func undoButton(_ sender: UIButton) {
        canvas.undo()
    }
    
    @IBAction func cleanButton(_ sender: UIButton) {
        canvas.clear()
    }
    
    @IBAction func changeLineSlider(_ sender: UISlider) {
        canvas.setStrokeWidht(width: CGFloat(sender.value))
    }
    
    @IBAction func changeColorButton(_ sender: UIButton) {
        canvas.setStrokeColor(color: sender.backgroundColor ?? .black)
    }
    
    //TODO: Saving image.
}

