//
//  HeroNode.swift
//  PencilAdventure
//
//  Created by Ankur Patel on 8/6/14.
//  Copyright (c) 2014 backstopmedia. All rights reserved.
//

import SpriteKit

// Note that these would normally be class properties, but Swift doesn't currently support class properties.
let SteveMaxFrames = 12
let SteveTextureNameBase = "steve"
var steveWalkingFrames = [SKTexture]()
//currently Steve can run, jump and Die
public enum HeroState {
    case Run, Jump, PowerUp, Death
}

public class HeroNode: SKSpriteNode {
    
    private let SteveAnimationFPS = 25.0
    private var powerUpParticle = SKEmitterNode(fileNamed: "PowerUpParticle")
    public var heroState: HeroState = .Run
    convenience init(scene: SKScene, withPhysicsBody: Bool) {
        
        let atlas = SKTextureAtlas(named: "Steve")
        for i in 1 ... SteveMaxFrames {
            let texName = "\(SteveTextureNameBase)\(i)"
            if let texture = atlas.textureNamed(texName) {
                steveWalkingFrames.append(texture)
            }
        }
        self.init(texture: steveWalkingFrames[0])
        
        name = "steve"
        xScale = scene.getSceneScaleX()
        yScale = scene.getSceneScaleY()
        zPosition = HeroZPosition
        speed = 1
        powerUpParticle.paused = true
        
        if withPhysicsBody {
            physicsBody = SKPhysicsBody(rectangleOfSize: self.size)
            physicsBody.dynamic = true
            physicsBody.allowsRotation = false
            physicsBody.mass = 0.6 // TODO - what to do about this?
            physicsBody.categoryBitMask = heroCategory
            physicsBody.collisionBitMask = levelCategory | sharpenerCategory | groundCategory | finishCategory
            physicsBody.contactTestBitMask = levelCategory | sharpenerCategory | groundCategory | finishCategory
        }
        
        self.addChild(powerUpParticle)
        
        self.runAction(
            SKAction.repeatActionForever(
                SKAction.animateWithTextures(steveWalkingFrames, timePerFrame:1.0 / SteveAnimationFPS, resize:false, restore:false)
            ), withKey:"steveRun"
        )
    }
    
    public func didGetPowerUp() {
        heroState = HeroState.PowerUp
        powerUpParticle.paused = false
        powerUpParticle.hidden = false
        callbackAfter(0.5) {
            self.powerUpParticle.paused = true
            self.powerUpParticle.hidden = true
            self.heroState = .Run
        }
        self.runAction(SKAction.playSoundFileNamed("collision.mp3", waitForCompletion: false))
    }
    
    public func die() {
        heroState = .Death
        //TODO run animation of death
        self.runAction(SKAction.playSoundFileNamed("collision.mp3", waitForCompletion: false))
    }
}
