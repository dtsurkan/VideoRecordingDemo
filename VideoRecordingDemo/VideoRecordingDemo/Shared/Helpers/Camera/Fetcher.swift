//
//  Fetcher.swift
//  Botl
//
//  Created by Dmitriy Tsurkan on 3/21/17.
//  Copyright © 2017 Botl. All rights reserved.
//

import UIKit
import Photos

struct Fetcher {
    
    // TODO: Why not use screen size?
    static func fetchImages(_ assets: [PHAsset], size: CGSize = CGSize(width: 720, height: 1280)) -> [UIImage] {
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        
        var images = [UIImage]()
        for asset in assets {
            PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: options) { image, _ in
                if let image = image {
                    images.append(image)
                }
            }
        }
        
        return images
    }
    
    static func fetchAsset(_ localIdentifer: String) -> PHAsset? {
        return PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifer], options: nil).firstObject
    }
}
