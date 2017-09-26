//
//  CaptureButton.swift
//  VideoRecordingDemo
//
//  Created by Dima Tsurkan on 9/26/17.
//  Copyright © 2017 Dima Tsurkan. All rights reserved.
//

import UIKit

class CaptureButton: UIButton {
    
    var progressColor: UIColor = UIColor(red: 0,
                                          green: 107/255,
                                          blue: 1,
                                          alpha: 1)
    
    
    
    var progress: CGFloat {
        get {
            return progressShape.strokeEnd
        } set {
            progressShape.strokeEnd = newValue
        }
    }
    
    var progressShape = CAShapeLayer()
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        backgroundColor = .clear
        let startAngle: CGFloat = .pi * 1.5
        let endAngle = startAngle + .pi * 2
        let center = CGPoint(x: bounds.width/2, y: bounds.height/2)
        let progressPath = UIBezierPath(arcCenter: center,
                                        radius: bounds.width / 2 - 2,
                                        startAngle: startAngle,
                                        endAngle: endAngle,
                                        clockwise: true)
        progressShape.path = progressPath.cgPath
        progressShape.backgroundColor = UIColor.clear.cgColor
        progressShape.fillColor = UIColor.clear.cgColor
        progressShape.strokeColor = progressColor.cgColor
        progressShape.lineWidth = 5
        progressShape.strokeStart = 0
        progressShape.strokeEnd = 0
        layer.addSublayer(progressShape)
    }
    
}

