//
//  Permission.swift
//  Botl
//
//  Created by Dmitriy Tsurkan on 3/21/17.
//  Copyright © 2017 Botl. All rights reserved.
//

import Foundation
import Photos
import AVFoundation

struct Permission {
    
    static var hasPermissions: Bool {
        return Photos.hasPermission && Camera.hasPermission
    }
    
    struct Photos {
        static var hasPermission: Bool {
            return PHPhotoLibrary.authorizationStatus() == .authorized
        }
        
        static func request(_ completion: @escaping () -> Void) {
            PHPhotoLibrary.requestAuthorization { status in
                completion()
            }
        }
    }
    
    struct Camera {
        static var hasPermission: Bool {
            return AVCaptureDevice.authorizationStatus(for: AVMediaType.video) == .authorized
        }
        
        static func request(_ completion: @escaping () -> Void) {
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { granted in
                completion()
            }
        }
    }
    
    struct Audio {
        static var hasPermission: Bool {
            return AVCaptureDevice.authorizationStatus(for: AVMediaType.audio) == .authorized
        }
        
        static func request(_ completion: @escaping () -> Void) {
            AVCaptureDevice.requestAccess(for: AVMediaType.audio) { granted in
                completion()
            }
        }
    }
}

