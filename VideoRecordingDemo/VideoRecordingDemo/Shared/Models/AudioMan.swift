//
//  AudioMan.swift
//  VideoRecordingDemo
//
//  Created by Dima Tsurkan on 9/26/17.
//  Copyright © 2017 Dima Tsurkan. All rights reserved.
//

import Foundation
import AVFoundation

protocol AudioManDelegate: class {
    func audioMan(_ audioMan: AudioMan,
                  failToStartRecording: NSError)
    
    func audioMan(_ audioMan: AudioMan,
                  didFinishRecording url: URL)
    
}

class AudioMan: NSObject {
    
    /// The maximum amount of seconds for audio duration.
    static let maxAudioDuration = 30.0
    
    weak var delegate: AudioManDelegate?
    var recordingSession: AVAudioSession = AVAudioSession.sharedInstance()
    var audioRecorder: AVAudioRecorder!
    /// Whether the `AudioMan` is recording audio now.
    var isRecordingAudio = false
    
    // MARK: - Setup
    
    func setup() {
        // TODO: this is going to be called always. So consider removing this check
        if Permission.Audio.hasPermission {
            start()
        }
    }
    
    // MARK: - Session
    
    
    fileprivate func start() {
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        
                    } else {
                        self.delegate?.audioMan(self, failToStartRecording: NSError(domain: "Error", code: 999, userInfo: ["message": "Audio recording failed"]))
                    }
                }
            }
        } catch {
            self.delegate?.audioMan(self, failToStartRecording: error as NSError)
        }
    }
    
    /// Asks  to start audio recording
    func startAudioRecording() {
        guard !isRecordingAudio else { return }
        isRecordingAudio = true
        
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
        } catch {
            self.delegate?.audioMan(self, failToStartRecording: error as NSError)
        }
    }
    
    /// Asks to stop video audio
    func stopAudioRecording() {
        guard isRecordingAudio else { return }
        isRecordingAudio = false
        audioRecorder.stop()
        audioRecorder = nil
    }
    
   
}


// MARK: - AVAudioRecorderDelegate

extension AudioMan: AVAudioRecorderDelegate {
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        audioRecorder.stop()
        audioRecorder = nil
        
        if flag {
            self.delegate?.audioMan(self, didFinishRecording: recorder.url)
        } else {
            self.delegate?.audioMan(self, failToStartRecording: NSError(domain: "Error", code: 99, userInfo: ["message": "Can't save recording"]))
        }
    }
}


// MARK: - Helper

extension AudioMan {
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
}
