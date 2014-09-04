//
//  SKShapeNode+Extensions.swift
//  PencilAdventure
//
//  Created by Ankur Patel on 8/2/14.
//  Copyright (c) 2014 backstopmedia. All rights reserved.
//

import SpriteKit

extension SKShapeNode {
    
    func log() {
        NSLog(" Name     : %@", name!)
        NSLog(" Position : %@, %@", position.x, position.y)
        NSLog(" Frame    : %@, %@ - %@ x %@", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height)
        NSLog(" Scale    : %@, %@", xScale, yScale)
        NSLog(" zRotation: %@", zRotation)
        NSLog(" zPosition: %@", zPosition)
    }
}