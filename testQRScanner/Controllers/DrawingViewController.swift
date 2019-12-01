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
    
    private let undoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Undo", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(handleUndo), for: .touchUpInside)
        return button
    }()
    
    @objc private func handleUndo() {
        canvas.undo()
    }
    
    private let clearButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Clear", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(handleClear), for: .touchUpInside)
        return button
    }()
    
    @objc private func handleClear() {
        canvas.clear()
    }
    
    private let slider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 1
        slider.maximumValue = 10
        slider.addTarget(self, action: #selector(handleSlideChange), for: .valueChanged)
        return slider
    }()
    
    @objc private func handleSlideChange() {
        canvas.setStrokeWidht(width: slider.value)
    }
    
    private let yellowButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .yellow
        button.layer.borderWidth = 1
        button.addTarget(self, action: #selector(handleColorChange), for: .touchUpInside)
        return button
    }()
    
    private let redButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .red
        button.layer.borderWidth = 1
        button.addTarget(self, action: #selector(handleColorChange), for: .touchUpInside)
        return button
    }()
    
    private let blueButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .blue
        button.layer.borderWidth = 1
        button.addTarget(self, action: #selector(handleColorChange), for: .touchUpInside)
        return button
    }()
    
    @objc private func handleColorChange(button: UIButton) {
        canvas.setStrokeColor(color: button.backgroundColor ?? .black)
    }
    
    override func loadView() {
        self.view = canvas
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        canvas.backgroundColor = .white
        
        setupLayout()
    }
    
    private func setupLayout() {
        let colorStackView = UIStackView(arrangedSubviews: [
            yellowButton,
            redButton,
            blueButton
        ])
        colorStackView.distribution = .fillEqually
        
        
        let stackView = UIStackView(arrangedSubviews: [
            undoButton,
            clearButton,
            colorStackView,
            slider
        ])
        
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.frame = CGRect(x: 0, y: 0, width: 200, height: 100)
        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        stackView
            .trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8).isActive = true
    }
}

