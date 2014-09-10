//
//  GameScene.swift
//  PencilAdventure
//
//  Created by Jocelyn Harrington on 7/29/14.
//  Copyright (c) 2014 backstopmedia. All rights reserved.
//

import SpriteKit


// Category masks
let heroCategory: UInt32 = 1 << 0
let groundCategory: UInt32 = 1 << 1
let levelCategory: UInt32 = 1 << 2
let powerupCategory: UInt32 = 1 << 3
let finishCategory: UInt32 = 1 << 5
class GameScene : SKScene, SKPhysicsContactDelegate {
    
    // We'll place a series of horizontal background tiles into the scene that will get a parallax
    // scroll. Let's define some information about the number of tiles we'll scroll through and
    // their sizes.
    private let backgroundTileCount = 2
    
    // charater
    var steve:SKSpriteNode!
    
    override func didMoveToView(view: SKView) {
        // Setup physics
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -9.8)
        physicsWorld.contactDelegate = self
        
        //add background
        addBackground()
        
        //add Steve
        addSteve()
        
        //add platform
        let platform = SKSpriteNode(imageNamed: "wall")
        platform.name = "Wall"
        platform.physicsBody = SKPhysicsBody(rectangleOfSize: platform.size)
        platform.physicsBody?.dynamic = false
        platform.physicsBody?.allowsRotation = false
        platform.physicsBody?.categoryBitMask = levelCategory
        platform.physicsBody?.collisionBitMask = heroCategory
        platform.position = CGPoint(x:380.0, y:200.0)
        platform.zPosition = 0
        addChild(platform)
        
        //add sharpener
        let sharpener = SKSpriteNode(imageNamed: "sharpener")
        sharpener.name = "Sharpener"
        sharpener.physicsBody = SKPhysicsBody(circleOfRadius: sharpener.size.width/2)
        sharpener.physicsBody?.dynamic = false
        sharpener.physicsBody?.allowsRotation = false
        sharpener.physicsBody?.categoryBitMask = powerupCategory
        sharpener.physicsBody?.collisionBitMask = heroCategory
        sharpener.position = CGPoint(x:380.0, y:240.0)
        sharpener.zPosition = 0
        addChild(sharpener)
        
        //add finish line
        let finish = SKSpriteNode(color: UIColor.clearColor(), size: CGSize(width: 5.0, height: frame.height))
        finish.name = "finish"
        finish.physicsBody = SKPhysicsBody(rectangleOfSize: finish.size)
        finish.physicsBody?.dynamic = false
        finish.physicsBody?.allowsRotation = false
        finish.physicsBody?.categoryBitMask = finishCategory
        finish.physicsBody?.collisionBitMask = heroCategory
        finish.position = CGPoint(x:480.0, y:frame.height*0.5)
        finish.zPosition = 0
        addChild(finish)
        
        //scrolling
        movingSprites()
        
        //add ground level
        addGroundLevel()
    }
    
    func addBackground() {
        let background = SKTexture(imageNamed: "background")
        let bgSprite = SKSpriteNode(texture: background)
        bgSprite.size = frame.size
        bgSprite.position = CGPoint(x: frame.size.width * 0.5, y: frame.size.height * 0.5)
        bgSprite.zPosition = -10
        addChild(bgSprite)
    }
    
    func addSteve() {
        steve = SKSpriteNode(imageNamed: "steve") //#1
        steve.name = "Steve"
        steve.physicsBody = SKPhysicsBody(rectangleOfSize: steve.size) //#2
        steve.physicsBody?.dynamic = true //#3
        steve.physicsBody?.allowsRotation = false //#4
        steve.physicsBody?.mass = 0.6 //#5
        steve.physicsBody?.categoryBitMask = heroCategory
        steve.physicsBody?.collisionBitMask = levelCategory | powerupCategory | groundCategory | finishCategory
        steve.physicsBody?.contactTestBitMask = levelCategory | powerupCategory | groundCategory | finishCategory
        steve.position = CGPoint(x:frame.size.width/4, y:frame.size.height/2)
        steve.zPosition = 1
        addChild(steve)
    }
    
    func movingPlatformFromLevel(sprite: SKSpriteNode) {
        //move the objects horizontally
        let distanceToMove = CGFloat(self.frame.size.width + sprite.size.width)
        let movePlatform = SKAction.moveByX(-distanceToMove, y:0.0, duration:NSTimeInterval(0.01 * distanceToMove))
        let removePlatform = SKAction.removeFromParent()
        let movePlatformAndRemove = SKAction.sequence([movePlatform, removePlatform])
        sprite.runAction(movePlatformAndRemove)
    }
    
    private func movingSprites() {
        // Find our sprites at z=0
        for child in self.children as [SKNode] {
            if let sprite = child as? SKSpriteNode {
                if sprite.zPosition == 0 {
                    movingPlatformFromLevel(sprite)
                }
            }
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        // touch to jump
        for touch: AnyObject in touches {
            steve.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 400))
        }
    }
    
    // Define physics world ground
    private func addGroundLevel() {
        let ground = SKSpriteNode(color: UIColor(white: 1.0, alpha: 0), size:CGSize(width: frame.size.width, height: 5))
        ground.position = CGPoint(x: frame.size.width/2, y: 0)
        ground.physicsBody = SKPhysicsBody(rectangleOfSize: ground.size)
        ground.physicsBody?.dynamic = false
        ground.physicsBody?.categoryBitMask = groundCategory
        ground.physicsBody?.collisionBitMask = heroCategory
        self.addChild(ground)
    }
        
    func didBeginContact(contact: SKPhysicsContact) {
        
        if (contact.bodyA.categoryBitMask & powerupCategory) == powerupCategory ||
            (contact.bodyB.categoryBitMask & powerupCategory) == powerupCategory {
                NSLog("get extra life")
        }
        
        if (contact.bodyA.categoryBitMask & levelCategory) == levelCategory ||
            (contact.bodyB.categoryBitMask & levelCategory) == levelCategory {
                NSLog("Steve can Jump")
        }
        
        if (contact.bodyA.categoryBitMask & groundCategory) == groundCategory ||
            (contact.bodyB.categoryBitMask & groundCategory) == groundCategory {
                gameEnd(false)
        }
        
        if (contact.bodyA.categoryBitMask & finishCategory) == finishCategory ||
            (contact.bodyB.categoryBitMask & finishCategory) == finishCategory {
                gameEnd(true)
        }
    }
    
    func gameEnd(didWin:Bool) {
        if didWin {
            NSLog("Yeah! You won!")
        } else {
            NSLog("Oh No! Game over!")
        }
        
    }
}
