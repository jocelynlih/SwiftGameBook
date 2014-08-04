//
//  Platform.swift
//  PencilAdventure
//
//  Created by Jocelyn Harrington on 8/3/14.
//  Copyright (c) 2014 backstopmedia. All rights reserved.
//

import SpriteKit

class Platform : SKSpriteNode {
    //platform category is 2
    let platformCategory: UInt32 = 1 << 1
    convenience init () {
        self.init(texture: nil, color: SKColor.whiteColor(), size: CGSize(width: 0, height: 0))
    }
    
    init(texture: SKTexture?, color: SKColor?, size: CGSize) {
        super.init(texture: texture, color:color, size:size)
    }

    func configurePhysicsBody() {
        physicsBody = SKPhysicsBody(rectangleOfSize: size)
        physicsBody.dynamic = false
        physicsBody.categoryBitMask = platformCategory
    }
}
