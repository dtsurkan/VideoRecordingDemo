//
//  EventHub.swift
//  Botl
//
//  Created by Dmitriy Tsurkan on 3/23/17.
//  Copyright © 2017 Botl. All rights reserved.
//

import Foundation

class EventHub {
    
    typealias Action = () -> Void
    
    static let shared = EventHub()
    
    // MARK: Initialization
    
    init() {}
    
    var close: Action?
    var doneWithImages: Action?
    var doneWithVideos: Action?
    var stackViewTouched: Action?
}
