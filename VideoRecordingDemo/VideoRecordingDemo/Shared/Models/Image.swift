//
//  Image.swift
//  Botl
//
//  Created by Dmitriy Tsurkan on 3/22/17.
//  Copyright © 2017 Botl. All rights reserved.
//

import UIKit
import Photos

public class Image: Equatable {
    
    let asset: PHAsset
    let imageUI: UIImage?
    
    // MARK: - Initialization
    
    init(asset: PHAsset, imageUI: UIImage?) {
        self.asset = asset
        self.imageUI = imageUI
    }
    
    // MARK: - 
    func getThumbnail(asset: PHAsset) -> UIImage? {
        
        var thumbnail: UIImage?
        
        let manager = PHImageManager.default()
        
        let options = PHImageRequestOptions()
        
        options.version = .original
        options.isSynchronous = true
        
        manager.requestImageData(for: asset, options: options) { data, _, _, _ in
            
            if let data = data {
                thumbnail = UIImage(data: data)
            }
        }
        
        return thumbnail
    }
}

// MARK: - Equatable

public func ==(lhs: Image, rhs: Image) -> Bool {
    return lhs.asset == rhs.asset
}
