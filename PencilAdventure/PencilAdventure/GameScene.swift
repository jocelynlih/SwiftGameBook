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
let SceneBackgroundZPosition: CGFloat = -20
let BackgroundZPosition: CGFloat = -10
let levelItemZPosition: CGFloat = 0
let EnemyZPosition: CGFloat = 30
let HeroZPosition: CGFloat = 90
let HUDZPosition: CGFloat = 100

// Category masks (including our hero, items that make up the level, etc.)
//
// Note that these would normally be class properties, but Swift doesn't currently support class properties.
let heroCategory: UInt32 = 1 << 0
let groundCategory: UInt32 = 1 << 1
let levelItemCategory: UInt32 = 1 << 2
let powerupCategory: UInt32 = 1 << 3
let deathtrapCategory: UInt32 = 1 << 4
let finishCategory: UInt32 = 1 << 5

class GameScene : SKScene, SKPhysicsContactDelegate, GameOverProtocol {
    // Background layer
    private let BackgroundScrollSpeedUnitsPerSecond: CGFloat = 200
    private var background:SKTexture!
	
	// Scrolling speed
	private let ScrollSpeedInUnitsPerSecond: CGFloat = 200
    
    // Our viewable area. This originates at the bottom/left corner and extends up/right in scene points.
    internal var viewableArea: CGRect!
    
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
        
		// Calculate our viewable area (in points)
		let viewToFrameScale = frame.width / view.frame.size.width
		viewableArea = CGRect()
		viewableArea.size.width = view.frame.size.width * viewToFrameScale
		viewableArea.size.height = view.frame.size.height * viewToFrameScale
		viewableArea.origin.x = (frame.size.width - viewableArea.size.width) / 2
		viewableArea.origin.y = (frame.size.height - viewableArea.size.height) / 2
		
		// Setup our level accessories (backgground items, powerups and deathtraps)
		//
		// It's important to do this before we add any of our additional nodes to
		// the scene (such as our hero, lifeline, etc.) since this goes through all
		// nodes and may modify their properties.
		setupAccessories()
		
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
        let backgroundScrollDist = backgroundWidth
        let frameCenter = CGPoint(x: frame.width / 2.0, y: frame.height / 2.0)
		
        // Setup our parallax scrolling actions
        //
        // The speed is based on the distance we need to travel, the relative speed and the number of tiles we
        // have to cover. Doing this allows our speed to stay the same even if we change backgroundTileCount.
        let scrollTime = backgroundScrollDist / BackgroundScrollSpeedUnitsPerSecond
        let scrollBgSprite = SKAction.moveByX(-backgroundScrollDist, y: 0, duration: NSTimeInterval(scrollTime))
        let resetBgSprite = SKAction.moveByX(backgroundScrollDist, y: 0, duration: 0.0)
        let moveBgSpritesForever = SKAction.repeatActionForever(SKAction.sequence([scrollBgSprite,resetBgSprite]))
        
        // Finally we can add the background tiles. We use two so we always have coverage
        for i in 0 ..< 2 {
            let bgSprite = SKSpriteNode(texture: background)
            bgSprite.size = frame.size
            bgSprite.position = CGPoint(x: frame.size.width/2.0 + backgroundScrollDist * CGFloat(i), y: frame.size.height/2.0)
            bgSprite.zPosition = SceneBackgroundZPosition
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
        
		// Setup the moving sprites
		setupMovingSprites()
		
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
	
	private func ensurePhysicsBody(sprite: SKSpriteNode, useTextureAlpha: Bool = true) -> Bool {
		// Make sure our sprite has a physicsBody
		if sprite.physicsBody == .None {
			
			// First, try to create a physicsBody from the texture alpha
			if useTextureAlpha && sprite.texture != .None {
				sprite.physicsBody = SKPhysicsBody(texture: sprite.texture, alphaThreshold: 0.9, size: sprite.size)
			}
			
			// Next, try to create a physicsBody from the sprite's smallest
			// bounding rectangle
			if sprite.physicsBody == .None {
				sprite.physicsBody = SKPhysicsBody(rectangleOfSize: sprite.frame.size)
			}
			
			// If we still don't have a physicsBody, just move on to the next one
			if sprite.physicsBody == nil {
				return false
			}
			
			// Default these to no collisions/contacts
			sprite.physicsBody.categoryBitMask = 0
			sprite.physicsBody.collisionBitMask = 0
			sprite.physicsBody.contactTestBitMask = 0

		}
		
		// Defaults for the physics body
		sprite.physicsBody.dynamic = false
		
		return true
	}
	
	private func setupAccessories() {
		// The Xcode level designer doesn't currently allow for any custom
		// data to be added to a node. So we've used the name field to add
		// additional information in the form of a sprite specification. We
		// format it like so:
		//
		//   <sprite name>|<accessory type>
		//
		// Therefore, a sprite named "picture|background" would represent a
		// sprite named "picture" that is a background accessory type. We
		// then remove the accessory type from the name and setup that accessory
		// type appropriately. That might include collision/contact masks,
		// z-position and/or other properties.
		for child in self.children as [SKNode] {
			if var sprite = child as? SKSpriteNode {
				
				// If the sprite doesn't have a name, we have no work to do here
				if sprite.name == .None {
					continue
				}
				
				// Initialize the zPosition to a level item
				sprite.zPosition = levelItemZPosition
				
				// Check our specification string for any accessory types applied
				// to the sprite
				if let spriteSpec = sprite.name {
					var components = spriteSpec.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: "|"))
					
					// If we have no accessory specification, assume this is just
					// a normal level item
					if (components.count <= 1) {
						if ensurePhysicsBody(sprite) {
							sprite.physicsBody.categoryBitMask |= levelItemCategory
							sprite.physicsBody.collisionBitMask |= heroCategory
						}
						continue
					}
					
					// The first component is the name. Replace the sprite's
					// name to remove the additional components. This is
					// necessary because other aspects of the codebase will
					// use the name to perform their work needed.
					sprite.name = components[0]
					components.removeAtIndex(0)
					
					// Loop through the components and apply the appropriate
					// properties to this sprite
					for accessory in components
					{
						switch accessory
						{
						case "background":
							// Backgrond items should be behind everything
							sprite.zPosition = BackgroundZPosition
							
						case "finish":
							if ensurePhysicsBody(sprite, useTextureAlpha: false) {
								sprite.physicsBody.categoryBitMask |= finishCategory
								sprite.physicsBody.collisionBitMask |= heroCategory
							}
							
							// We don't want to see the finish line
							sprite.alpha = 0
							
						case "powerup":
							if ensurePhysicsBody(sprite) {
								sprite.physicsBody.categoryBitMask |= powerupCategory
								sprite.physicsBody.contactTestBitMask |= heroCategory
							}

						case "death":
							if ensurePhysicsBody(sprite) {
								sprite.physicsBody.categoryBitMask |= deathtrapCategory
								sprite.physicsBody.collisionBitMask |= heroCategory
							}
							
						default:
							NSLog("Treating unknown accessory in sprite specifier as normal level item: \(accessory)")
							if ensurePhysicsBody(sprite) {
								sprite.physicsBody.categoryBitMask |= levelItemCategory
								sprite.physicsBody.collisionBitMask |= heroCategory
							}
						}
					}

				}
			}
		}
	}
	
    func movingPlatformFromLevel(sprite: SKSpriteNode) {
        // Move the objects horizontally at a constant rate
        let movePlatform = SKAction.moveByX(-ScrollSpeedInUnitsPerSecond, y:0.0, duration:NSTimeInterval(1))
        sprite.runAction(SKAction.repeatActionForever(movePlatform))
    }
    
    private func setupMovingSprites() {
        // Find our sprites at z<=0 (this will be all of our level items)
        for child in self.children as [SKNode] {
            if let sprite = child as? SKSpriteNode {
                if sprite.zPosition > SceneBackgroundZPosition && sprite.zPosition <= levelItemZPosition  {
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
		if (body.categoryBitMask & powerupCategory) == powerupCategory {
			if body.node == nil {
				return
			}
            steveTheSprite.didGetPowerUp()
			body.node.removeFromParent()
            starCountNode.addPoint()
            lifeLineNode.addLifeLine(0.1)
        }
		if (body.categoryBitMask & deathtrapCategory) == deathtrapCategory {
			if body.node == nil {
				return
			}
			steveTheSprite.die()
			gameEnd(false)
		}
		if (body.categoryBitMask & groundCategory) == groundCategory {
			if body.node == nil {
				return
			}
			steveTheSprite.die()
			gameEnd(false)
		}
        if (body.categoryBitMask & levelItemCategory) == levelItemCategory {
			if body.node == nil {
				return
			}
            steveTheSprite.heroState = .Run
        }
        
        if (body.categoryBitMask & finishCategory) == finishCategory {
			if body.node == nil {
				return
			}
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
		SKNode.cleanupScene(self)
		
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
