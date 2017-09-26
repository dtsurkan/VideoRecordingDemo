//
//  Album.swift
//  Botl
//
//  Created by Dmitriy Tsurkan on 3/23/17.
//  Copyright © 2017 Botl. All rights reserved.
//

import UIKit
import Photos

class Album {
    
    let collection: PHAssetCollection
    var items: [Image] = []
    var videos: [Video] = []
    
    // MARK: - Initialization
    
    init(collection: PHAssetCollection) {
        self.collection = collection
    }
    
    func reload() {
        items = []
        
        let itemsFetchResult = PHAsset.fetchAssets(in: collection, options: Utils.fetchOptions())
        itemsFetchResult.enumerateObjects({ (asset, count, stop) in
            if asset.mediaType == .image {
                self.items.append(Image(asset: asset, imageUI: nil))
            }
        })

        videos = []
        itemsFetchResult.enumerateObjects({ (asset, count, stop) in
            if asset.mediaType == .video {
                self.videos.append(Video(asset: asset))
            }
        })
    }
}
