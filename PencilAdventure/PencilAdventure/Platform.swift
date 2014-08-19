//
//  Platform.swift
//  PencilAdventure
//
//  Created by Jocelyn Harrington on 8/3/14.
//  Copyright (c) 2014 backstopmedia. All rights reserved.
//

import SpriteKit

class Platform : SKSpriteNode {
    
    // Platform category is 2
    let platformCategory: UInt32 = 1 << 1
    
    func configurePhysicsBody() {
        physicsBody = SKPhysicsBody(rectangleOfSize: size)
        physicsBody.dynamic = false
        physicsBody.categoryBitMask = platformCategory
    }
}
