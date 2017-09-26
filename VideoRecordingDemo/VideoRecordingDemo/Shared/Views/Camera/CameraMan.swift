//
//  CameraMan.swift
//  Botl
//
//  Created by Dmitriy Tsurkan on 3/21/17.
//  Copyright © 2017 Botl. All rights reserved.
//

import Foundation
import AVFoundation
import PhotosUI
import Photos

protocol CameraManDelegate: class {
//    func cameraManNotAvailable(_ cameraMan: CameraMan)
    func cameraManDidStart(_ cameraMan: CameraMan)
    func cameraMan(_ cameraMan: CameraMan,
                   didChangeInput input: AVCaptureDeviceInput)
    
    /**
     Called when `CameraMan` stops recording the video.
     - parameter cameraMan: The sender `CameraMan`.
     - parameter url: The `URL` that defines location of the record temp file.
     */
    func cameraMan(_ cameraMan: CameraMan,
                   didStopRecordingVideoAt url: URL)
    
    /**
     Called when `CameraMan` has finished saving the video to the Photos library.
     - parameter cameraMan: The sender `CameraMan`.
     - parameter video: The saved `Video?`. May be `nil`, if saving was failed for whatever reason.
     */
    func cameraMan(_ cameraMan: CameraMan,
                   didSave video: Video?)
    
}

class CameraMan: NSObject {
    
    /// The maximum amount of seconds for video duration.
    static let maxVideoDuration = 30.0
    
    /// The video recording frames per second number
    let fps = 30
    
    weak var delegate: CameraManDelegate?
    let session = AVCaptureSession()
    let queue = DispatchQueue(label: "com.botlapp.Gallery.Camera.SessionQueue", qos: .background)
    let savingQueue = DispatchQueue(label: "com.botlapp.Gallery.Camera.SavingQueue", qos: .background)
    
    var backCamera: AVCaptureDeviceInput?
    var frontCamera: AVCaptureDeviceInput?
    
    /// The microphone capture input for recording videos.
    var microphone: AVCaptureDeviceInput?
    var stillImageOutput: AVCaptureStillImageOutput?
    
    /// The movie capture output for recording videos.
    var movieOutput: AVCaptureMovieFileOutput?
    
    /// Whether the `CameraMan` is recording video now.
    var isRecordingVideo = false
    
    deinit {
        stop()
    }
    
    
    // MARK: - Setup
    
    func setup() {
        // TODO: this is going to be called always. So consider removing this check
        if Permission.Camera.hasPermission {
            start()
        //} else {
        //    delegate?.cameraManNotAvailable(self)
        }
    }
    
    func setupDevices() {
        // Input
        AVCaptureDevice
            .devices(for: AVMediaType.video).flatMap {
                return $0 as? AVCaptureDevice
            }.forEach {
                switch $0.position {
                case .front:
                    self.frontCamera = try? AVCaptureDeviceInput(device: $0)
                case .back:
                    self.backCamera = try? AVCaptureDeviceInput(device: $0)
                default:
                    break
                }
        }

        microphone = try? AVCaptureDeviceInput(device: AVCaptureDevice.default(for: AVMediaType.audio)!)
        
        // Output
        stillImageOutput = AVCaptureStillImageOutput()
        stillImageOutput?.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
        
        movieOutput = AVCaptureMovieFileOutput()
        movieOutput?.maxRecordedDuration = CMTime(seconds: CameraMan.maxVideoDuration,
                                                  preferredTimescale: .init(fps))
    }
    
    func addInput(_ input: AVCaptureDeviceInput) {
        configurePreset(input)
        
        if session.canAddInput(input) {
            session.addInput(input)
            
            DispatchQueue.main.async {
                self.delegate?.cameraMan(self, didChangeInput: input)
            }
        }
    }
    
    
    // MARK: - Session
    
    var currentInput: AVCaptureDeviceInput? {
        return session.inputs.first as? AVCaptureDeviceInput
    }
    
    fileprivate func start() {
        // Devices
        setupDevices()
        
        guard
            let camInput = backCamera,
            let micInput = microphone,
            let imageOutput = stillImageOutput,
            let movieOutput = movieOutput
            else { return }
        
        
        configureSession {
            addInput(camInput)
            if session.canAddInput(micInput) {
                session.addInput(micInput)
            }
            if session.canAddOutput(imageOutput) {
                session.addOutput(imageOutput)
            }
            if session.canAddOutput(movieOutput) {
                session.addOutput(movieOutput)
            }
        }
        
        queue.async {
            self.session.startRunning()
            
            DispatchQueue.main.async {
                self.delegate?.cameraManDidStart(self)
            }
        }
    }
    
    func stop() {
        self.session.stopRunning()
    }
    
    func switchCamera(_ completion: (() -> Void)? = nil) {
        guard let currentInput = currentInput
            else {
                completion?()
                return
        }
        
        queue.async {
            guard let input = (currentInput == self.backCamera) ? self.frontCamera : self.backCamera
                else {
                    DispatchQueue.main.async {
                        completion?()
                    }
                    return
            }
            
            self.configureSession {
                self.session.removeInput(currentInput)
                self.addInput(input)
            }
            
            DispatchQueue.main.async {
                completion?()
            }
        }
    }
    
    func takePhoto(_ previewLayer: AVCaptureVideoPreviewLayer,
                   location: CLLocation?,
                   completion: @escaping ((PHAsset?) -> Void)) {
        guard let connection = stillImageOutput?.connection(with: AVMediaType.video) else { return }
        
        connection.videoOrientation = Utils.videoOrientation()
        
        queue.async {
            self.stillImageOutput?.captureStillImageAsynchronously(from: connection) {
                buffer, error in
                
                guard error == nil, let buffer = buffer, CMSampleBufferIsValid(buffer),
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer),
                    let image = UIImage(data: imageData)
                    else {
                        DispatchQueue.main.async {
                            completion(nil)
                        }
                        return
                }
                
                self.savePhoto(image, location: location, completion: completion)
            }
        }
    }
    
    func savePhoto(_ image: UIImage, location: CLLocation?, completion: @escaping ((PHAsset?) -> Void)) {
        var localIdentifier: String?
        
        savingQueue.async {
            do {
                try PHPhotoLibrary.shared().performChangesAndWait {
                    let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
                    localIdentifier = request.placeholderForCreatedAsset?.localIdentifier
                    request.creationDate = Date()
                    request.location = location
                }
                
                DispatchQueue.main.async {
                    if let localIdentifier = localIdentifier {
                        completion(Fetcher.fetchAsset(localIdentifier))
                    } else {
                        completion(nil)
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
    
    /// Asks the `movieOutput` to start video recording
    func startVideoRecording() {
        guard !isRecordingVideo else { return }
        isRecordingVideo = true
        guard let connection = movieOutput?.connection(with: AVMediaType.video) else { return }
        connection.videoOrientation = Utils.videoOrientation()
        queue.async {
            let tempURL = FileManager.default.urls(for: .documentDirectory,
                                                   in: .userDomainMask)[0]
                .appendingPathComponent("tempMovie")
                .appendingPathExtension("mov")
            self.movieOutput?.startRecording(to: tempURL,
                                             recordingDelegate: self)
        }
    }
    
    /// Asks the `movieOutput` to stop video recording
    func stopVideoRecording() {
        guard isRecordingVideo else { return }
        queue.async {
            self.movieOutput?.stopRecording()
        }
    }
    
    /**
     Saves the record file at specified `URL` to the Photos library.
     - parameter url: The `URL` of the record file.
     - parameter location: The `CLLocation?` that defines geographic location of the record.
     */
    func saveVideo(at url: URL, location: CLLocation?) {
        savingQueue.async {
            var localIdentifier: String?
            PHPhotoLibrary.shared().performChanges({
                let request = PHAssetChangeRequest
                    .creationRequestForAssetFromVideo(atFileURL: url)
                localIdentifier = request?.placeholderForCreatedAsset?.localIdentifier
                request?.creationDate = Date()
                request?.location = location
            }) { saved, error in
                var video: Video?
                if  saved,
                    let localIdentifier = localIdentifier,
                    let asset = Fetcher.fetchAsset(localIdentifier)
                {
                    print("The video was successfully saved")
                    video = Video(asset: asset)
                }
                try? FileManager.default.removeItem(at: url)
                DispatchQueue.main.async {
                    self.delegate?.cameraMan(self, didSave: video)
                }
            }
        }
    }
    
    func flash(_ mode: AVCaptureDevice.FlashMode) {
//        guard let device = currentInput?.device , device.isFlashModeSupported(mode) else { return }
//
//        queue.async {
//            self.lock {
//                device.flashMode = mode
//            }
//        }
        
        guard let device = currentInput?.device , device.isFlashModeSupported(mode) else { return }
        
        queue.async {
            self.lock {
                device.flashMode = mode
            }
        }

        
    }
    
    func focus(_ point: CGPoint) {
        guard let device = currentInput?.device , device.isFocusModeSupported(AVCaptureDevice.FocusMode.locked) else { return }
        
        queue.async {
            self.lock {
                device.focusPointOfInterest = point
            }
        }
    }
    
    // MARK: - Lock
    
    func lock(_ block: () -> Void) {
        if let device = currentInput?.device , (try? device.lockForConfiguration()) != nil {
            block()
            device.unlockForConfiguration()
        }
    }
    
    // MARK: - Configure
    
    /// Configures the `AVCaptureSession`
    func configureSession(_ block: () -> Void) {
        session.beginConfiguration()
        block()
        session.commitConfiguration()
    }
    
    // MARK: - Preset
    
    func configurePreset(_ input: AVCaptureDeviceInput) {
        for asset in preferredPresets() {
            if input.device.supportsSessionPreset(AVCaptureSession.Preset(rawValue: asset)) && self.session.canSetSessionPreset(AVCaptureSession.Preset(rawValue: asset)) {
                self.session.sessionPreset = AVCaptureSession.Preset(rawValue: asset)
                return
            }
        }
    }
    
    func preferredPresets() -> [String] {
        return [
            AVCaptureSession.Preset.high.rawValue,
            AVCaptureSession.Preset.medium.rawValue,
            AVCaptureSession.Preset.low.rawValue
        ]
    }
    
}

// MARK: - AVCaptureFileOutputRecordingDelegate

extension CameraMan: AVCaptureFileOutputRecordingDelegate {
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        isRecordingVideo = false
        DispatchQueue.main.async {
            self.delegate?.cameraMan(self,
                                     didStopRecordingVideoAt: outputFileURL)
        }
    }
    
    
    func capture(_ captureOutput: AVCaptureFileOutput!,
                 didStartRecordingToOutputFileAt fileURL: URL!,
                 fromConnections connections: [Any]!) {
    }
    
    func capture(_ captureOutput: AVCaptureFileOutput!,
                 didFinishRecordingToOutputFileAt outputFileURL: URL!,
                 fromConnections connections: [Any]!,
                 error: Error!) {
        isRecordingVideo = false
        DispatchQueue.main.async {
            self.delegate?.cameraMan(self,
                                     didStopRecordingVideoAt: outputFileURL)
        }
    }
    
}

