//
//  CameraView.swift
//  Botl
//
//  Created by Dmitriy Tsurkan on 3/21/17.
//  Copyright © 2017 Botl. All rights reserved.
//

import UIKit
import AVFoundation

protocol CameraViewDelegate: class {
    func cameraView(_ cameraView: CameraView, didTouch point: CGPoint)
}

class CameraView: UIView {
    
    // MARK: - Properties
    
    lazy var tapGR: UITapGestureRecognizer = {
        let gr = UITapGestureRecognizer(target: self, action: #selector(viewTapped(_:)))
        gr.delegate = self
        return gr
    }()
    
    lazy var focusImageView: UIImageView =  {
        let view = UIImageView()
        view.frame.size = CGSize(width: 110, height: 110)
        view.image = UIImage(named: "Crosshair")
        view.backgroundColor = .clear
        view.alpha = 0
        return view
    }()
    
    lazy var shutterOverlayView: UIView = {
        let view = UIView()
        view.alpha = 0
        view.backgroundColor = .black
        return view
    }()
    
    lazy var stackView: StackView = {
        let view = StackView(frame: self.frame)
        return view
    }()
    
    lazy var flashButton: TripleButton = {
        let states: [TripleButton.State] = [
            TripleButton.State(title: "Gallery.Camera.Flash.Off".g_localize(fallback: "OFF"), image: UIImage(named: "gallery_camera_flash_off")!),
            TripleButton.State(title: "Gallery.Camera.Flash.On".g_localize(fallback: "ON"), image: UIImage(named: "gallery_camera_flash_on")!),
            TripleButton.State(title: "Gallery.Camera.Flash.Auto".g_localize(fallback: "AUTO"), image: UIImage(named: "gallery_camera_flash_auto")!)
        ]
        
        let button = TripleButton(states: states)
        
        return button
    }()
    
    lazy var blurView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: effect)
        return blurView
    }()
    
    lazy var rotateOverlayView: UIView = {
        let view = UIView()
        view.alpha = 0
        return view
    }()
    
    var previewLayer: AVCaptureVideoPreviewLayer?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?

    weak var delegate: CameraViewDelegate?
    var timer: Timer?
    
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = .black
        setup()
    }

    
    // MARK: - Methods
    
    func setup() {
        addGestureRecognizer(tapGR)
        
        rotateOverlayView.addSubview(blurView)
        insertSubview(rotateOverlayView, belowSubview: stackView)
        
        addSubview(stackView)
        insertSubview(focusImageView, belowSubview: stackView)
        insertSubview(shutterOverlayView, belowSubview: focusImageView)
        addSubview(flashButton)
        
        rotateOverlayView.g_pinEdges()
        blurView.g_pinEdges()
        shutterOverlayView.g_pinEdges()
    }
    
    func setupPreviewLayer(_ session: AVCaptureSession) {
        guard
            previewLayer == nil
            else { return }
        
        let newLayer = AVCaptureVideoPreviewLayer(session: session)
        newLayer.autoreverses = true
        newLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        newLayer.frame = layer.bounds
        
        layer.insertSublayer(newLayer, at: 0)
        previewLayer = newLayer
    }

    func setupVideoPreviewLayer(_ session: AVCaptureSession) {
        guard previewLayer == nil else { return }

        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.autoreverses = true
        layer.videoGravity = AVLayerVideoGravity.resize

        self.layer.insertSublayer(layer, at: 0)
        layer.frame = self.layer.bounds

        videoPreviewLayer = layer
    }
    
    
    // MARK: - Actions
    
    @objc func viewTapped(_ gr: UITapGestureRecognizer) {
        let point = gr.location(in: self)
        
        focusImageView.transform = CGAffineTransform.identity
        timer?.invalidate()
        delegate?.cameraView(self, didTouch: point)
        
        focusImageView.center = point
        
        UIView.animate(withDuration: 0.5, animations: {
            self.focusImageView.alpha = 1
            self.focusImageView.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        }, completion: { _ in
            self.timer = Timer.scheduledTimer(timeInterval: 1, target: self,
                                              selector: #selector(CameraView.timerFired(_:)), userInfo: nil, repeats: false)
        })
    }
    
    // MARK: - Timer
    
    @objc func timerFired(_ timer: Timer) {
        UIView.animate(withDuration: 0.3, animations: {
            self.focusImageView.alpha = 0
        }, completion: { _ in
            self.focusImageView.transform = CGAffineTransform.identity
        })
    }
}



// MARK: - UIGestureRecognizerDelegate
extension CameraView: UIGestureRecognizerDelegate {
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let point = gestureRecognizer.location(in: self)
        
        return point.y > self.frame.maxY
            && point.y <  self.frame.size.height //bottomContainer.frame.origin.y
    }
    
}
