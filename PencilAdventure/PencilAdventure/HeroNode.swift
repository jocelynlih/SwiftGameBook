//
//  HeroNode.swift
//  PencilAdventure
//
//  Created by Ankur Patel on 8/6/14.
//  Copyright (c) 2014 backstopmedia. All rights reserved.
//

import SpriteKit

public class HeroNode: SKSpriteNode {

    private let SteveAnimationFPS = 25.0
    private var powerUpParticle = SKEmitterNode(fileNamed: "PowerUpParticle")
    
    convenience init(textures: [SKTexture]!, xScale: CGFloat, yScale: CGFloat, postition: CGRect, zPosition: CGFloat) {
        
        self.init(texture: textures[0])
        
        self.name = "steve"
        self.xScale = xScale
        self.yScale = yScale
        self.physicsBody = SKPhysicsBody(rectangleOfSize: self.size)
        self.physicsBody.dynamic = true
        self.physicsBody.allowsRotation = false
        self.physicsBody.mass = 0.3 // TODO - what to do about this?
        self.position = CGPoint(x: postition.size.width/4, y: postition.size.height/2)
        self.zPosition = zPosition

        powerUpParticle.paused = true
        
        self.addChild(powerUpParticle)
        
        self.runAction(
            SKAction.repeatActionForever(
                SKAction.animateWithTextures(textures, timePerFrame:1.0 / SteveAnimationFPS, resize:false, restore:false)
            ), withKey:"steveRun"
        )
    }
    
    public func didGetPowerUp() {
        powerUpParticle.paused = false
        powerUpParticle.hidden = false
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC / 2)), dispatch_get_main_queue()) {
            self.powerUpParticle.paused = true
            self.powerUpParticle.hidden = true
        }
    }
}
