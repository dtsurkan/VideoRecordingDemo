//
//  Once.swift
//  Botl
//
//  Created by Dmitriy Tsurkan on 3/21/17.
//  Copyright © 2017 Botl. All rights reserved.
//

import Foundation

class Once {
    
    var already: Bool = false
    
    func run(_ block: () -> Void) {
        guard !already else { return }
        
        block()
        already = true
    }
}
