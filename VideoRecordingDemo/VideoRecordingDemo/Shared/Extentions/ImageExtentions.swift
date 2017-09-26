//
//  ImageExtentions.swift
//  VideoRecordingDemo
//
//  Created by Dima Tsurkan on 9/26/17.
//  Copyright © 2017 Dima Tsurkan. All rights reserved.
//

import UIKit
import Photos

extension UIImageView {
    
    func g_loadImage(_ asset: PHAsset) {
        guard frame.size != CGSize.zero
            else {
                image = UIImage(named: "gallery_placeholder")
                return
        }
        
        if tag == 0 {
            image = UIImage(named: "gallery_placeholder")
        } else {
            PHImageManager.default().cancelImageRequest(PHImageRequestID(tag))
        }
        
        let options = PHImageRequestOptions()
        
        let id = PHImageManager.default().requestImage(for: asset, targetSize: frame.size,
                                                       contentMode: .aspectFill, options: options)
        { [weak self] image, _ in
            
            self?.image = image
        }
        
        tag = Int(id)
    }
}

