//
//  SwiftExtentions.swift
//  VideoRecordingDemo
//
//  Created by Dima Tsurkan on 9/26/17.
//  Copyright © 2017 Dima Tsurkan. All rights reserved.
//

import Foundation

// Extend Array
extension Array {
    
    mutating func g_moveToFirst(_ index: Int) {
        guard index != 0 && index < count else { return }
        
        let item = self[index]
        remove(at: index)
        insert(item, at: 0)
    }
}

extension String {
    
    func g_localize(fallback: String) -> String {
        let string = NSLocalizedString(self, comment: "")
        return string == self ? fallback : string
    }
}
