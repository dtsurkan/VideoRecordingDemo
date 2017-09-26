//
//  AudioRecordingViewController.swift
//  VideoRecordingDemo
//
//  Created by Dima Tsurkan on 9/26/17.
//  Copyright (c) 2017 Dima Tsurkan. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

protocol AudioRecordingDisplayLogic: class {
   
}

class AudioRecordingViewController: UIViewController, AudioRecordingDisplayLogic {
    var interactor: AudioRecordingBusinessLogic?
    var router: (NSObjectProtocol & AudioRecordingRoutingLogic & AudioRecordingDataPassing)?
    
    /// The `Timer` that defines video recording progress
    var progressTimer: Timer?
    
    /// The `CGfloat` that defines video recording progress rate (0...1)
    var progress: CGFloat = 0
    
    /// The video recording progress update step, in seconds
    let step = 0.05
    
    lazy var audioMan: AudioMan = {
        let man = AudioMan()
        man.delegate = self
        return man
    }()
    
    @IBOutlet weak var captureButton: CaptureButton!

    // MARK: Object lifecycle
  
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
  
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
  
    // MARK: Setup
  
    private func setup() {
        let viewController = self
        let interactor = AudioRecordingInteractor()
        let presenter = AudioRecordingPresenter()
        let router = AudioRecordingRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }
    
    // MARK: View lifecycle
  
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        captureButton.progress = 0
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        progressTimer?.invalidate()
    }
  
    // MARK: - Actions
    
    @IBAction func camptureButtonTouched(_ sender: UIButton) {
        progressTimer = .scheduledTimer(timeInterval: step,
                                        target: self,
                                        selector: #selector(updateProgress),
                                        userInfo: nil,
                                        repeats: true)
        startAudioRecording()
    }
    
    @IBAction func camptureButtonReleased(_ sender: UIButton) {
        stopAudioRecording()
        progressTimer?.invalidate()
    }
    
    // MARK: - Internal
    
    @objc private func updateProgress() {
        guard progress < 1 else {
            progressTimer?.invalidate()
            return
        }
        progress = progress + CGFloat(step/AudioMan.maxAudioDuration)
        captureButton.progress = progress
    }
    
    private func configureView() {
        askPermission()
    }
    
    private func askPermission() {
        if Permission.Audio.hasPermission {
            audioMan.setup()
        } else {
            Permission.Audio.request {
                if Permission.Audio.hasPermission {
                    self.audioMan.setup()
                }
            }
        }
    }
    
    private func startAudioRecording() {
        audioMan.startAudioRecording()
    }
    
    private func stopAudioRecording() {
        captureButton.progress = 0
        audioMan.stopAudioRecording()
    }
}

// MARK: - AudioManDelegate
extension AudioRecordingViewController: AudioManDelegate {
   
    func audioMan(_ audioMan: AudioMan, failToStartRecording: NSError) {
        
    }
    
    func audioMan(_ audioMan: AudioMan, didFinishRecording url: URL) {
        
    }
    
    
}
