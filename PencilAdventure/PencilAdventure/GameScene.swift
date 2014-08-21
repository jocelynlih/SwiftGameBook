//
//  GameScene.swift
//  PencilAdventure
//
//  Created by Jocelyn Harrington on 7/29/14.
//  Copyright (c) 2014 backstopmedia. All rights reserved.
//

import SpriteKit
import GameKit

// The scene has sketch sprites added, which are in front of each sprite. We then need to ensure that our
// enemies and hero are in front of them (and their sketches). We'll play with these numbers as development
// progresses to ensure that they are indeed in front. Here are some good defaults:
//
// Note that these would normally be class properties, but Swift doesn't currently support class properties.
let EnemyZPosition: CGFloat = 30
let HeroZPosition: CGFloat = 90
let HUDZPosition: CGFloat = 100

// Category masks (including our hero, items that make up the level, etc.)
//
// Note that these would normally be class properties, but Swift doesn't currently support class properties.
let heroCategory: UInt32 = 1 << 0
let levelCategory: UInt32 = 1 << 1
let sharpenerCategory: UInt32 = 1 << 2
let groundCategory: UInt32 = 1 << 3
let finishCategory: UInt32 = 1 << 4

class GameScene : SKScene, SKPhysicsContactDelegate, GameOverProtocol {
    // Background layer
    private let BackgroundScrollSpeed: CGFloat = 0.01
    private var background:SKTexture!
	
	// Scrolling speed
	private let ScrollSpeedInUnitsPerSecond: CGFloat = 100
    
    // Our viewable area. This originates at the bottom/left corner and extends up/right in scene points.
    internal var viewableArea: CGRect!
    
    // We'll place a series of horizontal background tiles into the scene that will get a parallax
    // scroll. Let's define some information about the number of tiles we'll scroll through and
    // their sizes.
    private let backgroundTileCount = 2
    
    // Sketch lines animation
    private let SketchAnimationFPS = 8.0
    private var sketchAnimationTimer: NSTimer?
    
    // Steve (our hero)
    private var steveTheSprite: HeroNode!
    
    // Pencil lifeline
    private var lifeLineNode: LifeLineNode!
    
    // Star Count
    private var starCountNode: StarCountNode!
    
    override func didMoveToView(view: SKView) {
        // Setup physics
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -9.8)
        physicsWorld.contactDelegate = self
        
        // Create the background layer sprite
        // TODO: We need a better solution which allows us to select the proper background based on the level
        let background = SKTexture(imageNamed: "house_background")
        
        // Make it cheap to draw
        background.filteringMode = SKTextureFilteringMode.Nearest
        
        // Note that our background width uses 'frame.width'. This is because our scene is set to
        // AspectFill (and because we're a landscape game) SpriteKit will automatically scale everything
        // in the scene's viewport (including the background) to fill the screen horizontally. These
        // scaled dimensions are stored in 'SKScene.frame'.
        let backgroundWidth = frame.width
        
        // Our total scroll distance. We calculate this based on the width of the background sprite
        // which will be tiled backgroundTiles times. Note that we scroll one less than this to avoid
        // scrolling past the trailing edge of the last tile.
        let backgroundScrollDist = backgroundWidth * CGFloat(backgroundTileCount - 1)
        let frameCenter = CGPoint(x: frame.width / 2.0, y: frame.height / 2.0)
        
        // Calculate our viewable area (in points)
        let viewToFrameScale = frame.width / view.frame.size.width
        viewableArea = CGRect()
        viewableArea.size.width = view.frame.size.width * viewToFrameScale
        viewableArea.size.height = view.frame.size.height * viewToFrameScale
        viewableArea.origin.x = (frame.size.width - viewableArea.size.width) / 2
        viewableArea.origin.y = (frame.size.height - viewableArea.size.height) / 2
        
        // Setup our parallax scrolling actions
        //
        // The speed is based on the distance we need to travel, the relative speed and the number of tiles we
        // have to cover. Doing this allows our speed to stay the same even if we change backgroundTileCount.
        let scrollTime = backgroundScrollDist * BackgroundScrollSpeed * CGFloat(backgroundTileCount)
        let scrollBgSprite = SKAction.moveByX(-backgroundScrollDist, y: 0, duration: NSTimeInterval(scrollTime))
        let resetBgSprite = SKAction.moveByX(backgroundScrollDist, y: 0, duration: 0.0)
        let moveBgSpritesForever = SKAction.repeatActionForever(SKAction.sequence([scrollBgSprite,resetBgSprite]))
        
        // Finally we can add the background tiles
        for i in 0..<backgroundTileCount {
            let bgSprite = SKSpriteNode(texture: background)
            bgSprite.size = frame.size
            bgSprite.position = CGPoint(x: frame.size.width/2.0 + backgroundScrollDist * CGFloat(i), y: frame.size.height/2.0)
            bgSprite.zPosition = -10
            bgSprite.runAction(moveBgSpritesForever)
            addChild(bgSprite)
        }
        
        // Give our root scene a name
        name = "SceneRoot"
        
        // Create our hero
        steveTheSprite = HeroNode(scene: self, withPhysicsBody: true)
        steveTheSprite.position = CGPoint(x: scene.frame.size.width/4, y: scene.frame.size.height/2)
        
        lifeLineNode = LifeLineNode(forScene: self)
        starCountNode = StarCountNode(forScene: self)
        
        addChild(steveTheSprite)
        addChild(lifeLineNode)
        addChild(starCountNode)
        
        // Attach our sketch nodes to all sprites
        SketchRender.attachSketchNodes(self)
        
		// Move sprites
        movingSprites()
		
        // Add ground level
        addGroundLevel()
        
        // Setup a timer for the update
        sketchAnimationTimer = NSTimer.scheduledTimerWithTimeInterval(1.0 / SketchAnimationFPS, target: self, selector: Selector("sketchAnimationTimer:"), userInfo: nil, repeats: true)
    }
    
    private func scaleToFillScreenWithAspect(srcSize: CGSize, targetSize: CGSize) -> CGFloat {
        // Find the dimension that has to grow the most
        let deltaWidth = abs(targetSize.width - srcSize.width)
        let deltaHeight = abs(targetSize.height - srcSize.height)
        
        if deltaWidth > deltaHeight {
            return targetSize.width / srcSize.width
        } else {
            return targetSize.height / srcSize.height
        }
    }
    
    func movingPlatformFromLevel(sprite: SKSpriteNode) {
        // Move the objects horizontally at a constant rate
        let movePlatform = SKAction.moveByX(-ScrollSpeedInUnitsPerSecond, y:0.0, duration:NSTimeInterval(1))
        sprite.runAction(SKAction.repeatActionForever(movePlatform))
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
    
    //TODO: we can add more action later, to keep the demo simple, we use touch to jump for now
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        // only jump when steve is running
        if (steveTheSprite.heroState == HeroState.Run) {
            // touch to jump
            for touch: AnyObject in touches {
                let location = touch.locationInNode(self)
                steveTheSprite.physicsBody.velocity = CGVector(dx: 0, dy: 50)
                steveTheSprite.physicsBody.applyImpulse(CGVector(dx: 0, dy: 400))
                steveTheSprite.heroState = HeroState.Jump
            }
        }
    }
    
    // Define physics world ground
    private func addGroundLevel() {
        let ground = SKSpriteNode(color: UIColor(white: 1.0, alpha: 0), size:CGSize(width: frame.size.width, height: 5))
        
        // The ground is at the bottom of our viewable area
        ground.position = CGPoint(x: self.frame.size.width/2, y: self.viewableArea.origin.y)
        ground.physicsBody = SKPhysicsBody(rectangleOfSize: ground.size)
        ground.physicsBody.dynamic = false
        //TODO: need to have this comment out for building the game level.
        ground.physicsBody.categoryBitMask = groundCategory
        ground.physicsBody.collisionBitMask = heroCategory
        self.addChild(ground)
        // add a wall to the left edge of view and detect if character runs into it
        let wall = SKSpriteNode(color: UIColor(white: 1.0, alpha: 0), size: CGSize(width: 5, height: frame.size.height))
        wall.position = CGPoint(x: self.viewableArea.origin.x, y: self.viewableArea.size.height/2)
        wall.physicsBody = SKPhysicsBody(rectangleOfSize: wall.size)
        wall.physicsBody.dynamic = false
        wall.physicsBody.categoryBitMask = groundCategory
        wall.physicsBody.collisionBitMask = heroCategory
        self.addChild(wall)
    }
    
    func steveDidColliadeWith(body: SKPhysicsBody) {
        if (body.categoryBitMask & sharpenerCategory) == sharpenerCategory {
            NSLog("get extra life")
            steveTheSprite.didGetPowerUp()
            starCountNode.addPoint()
            lifeLineNode.addLifeLine(0.1)
        }
        if (body.categoryBitMask & groundCategory) == groundCategory {
            NSLog("Oh No! Game over")
            steveTheSprite.die()
            gameEnd(false)
        }
        if (body.categoryBitMask & levelCategory) == levelCategory {
            NSLog("Steve can Jump")
            steveTheSprite.heroState = .Run
        }
        
        if (body.categoryBitMask & finishCategory) == finishCategory {
            NSLog("You Won")
            gameEnd(true)
            steveTheSprite.heroState = .Run
        }
    }
	
    func didBeginContact(contact: SKPhysicsContact) {
        if let steve = contact.bodyA.node as? HeroNode {
            steveDidColliadeWith(contact.bodyB)
        }
        if let steve = contact.bodyB.node as? HeroNode {
            steveDidColliadeWith(contact.bodyA)
        }
    }
    
    func sketchAnimationTimer(timer: NSTimer) {
        animateSketchSprites(self)
    }
    
    private func animateSketchSprites(node: SKNode) {
        var sketchSprites: [SKSpriteNode] = []
        
        // Find our sketch sprites
        for child in node.children as [SKNode] {
            // Depth-first traversal
            //
            // Note that we don't bother to traverse into our sketch sprites
            if child.name != SketchName {
                animateSketchSprites(child)
            }
            
            if let sprite = child as? SKSpriteNode {
                // We need a name
                if let name = sprite.name {
                    if name == SketchName {
                        // If it's hidden, let's add it to our list of possible sprites to un-hide
                        if sprite.hidden {
                            sketchSprites.append(sprite)
                        } else {
                            // This is the one that's already been visible, so let's make sure we get a different one
                            // by not adding it to the list. We do, however, want to hide it.
                            sprite.hidden = true
                        }
                    }
                }
            }
        }
        
        // If we found a set of sketch sprites, then unhide just one of them
        if sketchSprites.count != 0 {
            let rnd = arc4random_uniform(UInt32(sketchSprites.count))
            sketchSprites[Int(rnd)].hidden = false
        }
    }
    //TODO: need game end scene for logic here
    func gameEnd(didWin:Bool) {
        if (didWin) {
            self.view.presentScene(LevelFinishedScene())
        } else {
            let gameOverScene = GameOverScene()
            gameOverScene.level = 2
            self.view.presentScene(gameOverScene)
        }
        onGameOver()
    }
    
    func onGameOver() {
        ScoreManager.saveScore(starCountNode.getPoints(), forLevel: 1)
    }
}
