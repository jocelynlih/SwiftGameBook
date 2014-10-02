//
//  GameScene.swift
//  PencilAdventure
//
//  Created by Jocelyn Harrington on 7/29/14.
//  Copyright (c) 2014 backstopmedia. All rights reserved.
//

import SpriteKit
import GameKit

// Category masks (including our hero, items that make up the level, etc.)
//
// Note that these would normally be class properties, but Swift doesn't currently support class properties.
let heroCategory: UInt32 = 1 << 0
let groundCategory: UInt32 = 1 << 1
let levelItemCategory: UInt32 = 1 << 2
let powerupCategory: UInt32 = 1 << 3
let deathtrapCategory: UInt32 = 1 << 4
let finishCategory: UInt32 = 1 << 5

public class GameScene : PaperScene, SKPhysicsContactDelegate, GameProtocol {
	// Scrolling speed
	private let ScrollSpeedInUnitsPerSecond: CGFloat = 200
    
	// Steve (our hero)
	private var steveTheSprite: HeroNode!
	
	// Pencil lifeline
	private var lifeLineNode: LifeLineNode!
	
	// Star Count
	private var starCountNode: StarCountNode!
	
    public var currentLevel = 1
    public override func didMoveToView(view: SKView) {
		super.didMoveToView(view)
		
		// Create our hero
		steveTheSprite = HeroNode(scene: self, withPhysicsBody: true)
		steveTheSprite.position = CGPoint(x: scene!.frame.size.width * 0.25, y: scene!.frame.size.height * 0.5)
		
		lifeLineNode = LifeLineNode(forScene: self)
		starCountNode = StarCountNode(forScene: self)
		
		addChild(steveTheSprite)
		addChild(lifeLineNode)
		addChild(starCountNode)
		
		// Setup the moving sprites
		setupMovingSprites()
		
		// Add ground level
		addGroundLevel()
    }
	
	public func prepareLevel() {
        var isSketchMode = NSUserDefaults.standardUserDefaults().boolForKey("SketchMode")
        
        if isSketchMode {
            setupBackground(true)
        } else {
            if currentLevel == 3 || currentLevel == 4 {
                setupOutdoorBackground()
            } else {
                setupBackground(true)
            }
        }
		
		// Setup physics
		physicsWorld.gravity = CGVector(dx: 0.0, dy: -9.8)
		physicsWorld.contactDelegate = self
		
		// Setup our level accessories (backgground items, powerups and deathtraps)
		//
		// It's important to do this before we add any of our additional nodes to
		// the scene (such as our hero, lifeline, etc.) since this goes through all
		// nodes and may modify their properties.
		setupAccessories()
		
		// Give our root scene a name
		name = "SceneRoot"
        
        if currentLevel == 1 || isSketchMode {
            // Convert everyting in the level into sketches
            convertToSketch()
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
				NSLog("*** Falling back to rectangle for sprite: \(sprite.name)")
				sprite.physicsBody = SKPhysicsBody(rectangleOfSize: sprite.frame.size)
			}
			
			// If we still don't have a physicsBody, just move on to the next one
			if sprite.physicsBody == nil {
				NSLog("*** Falling back to no physicsBody for sprite: \(sprite.name)")
				return false
			}
			
			// Default these to no collisions/contacts
			sprite.physicsBody?.categoryBitMask = 0
			sprite.physicsBody?.collisionBitMask = 0
			sprite.physicsBody?.contactTestBitMask = 0
		}
		
		// Defaults for the physics body
		sprite.physicsBody?.dynamic = false
		
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
							sprite.physicsBody?.categoryBitMask |= levelItemCategory
							sprite.physicsBody?.collisionBitMask |= heroCategory
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
								sprite.physicsBody?.categoryBitMask |= finishCategory
								sprite.physicsBody?.collisionBitMask |= heroCategory
							}
							
							// We don't want to see the finish line
							sprite.alpha = 0
							
						case "powerup":
							if ensurePhysicsBody(sprite) {
								sprite.physicsBody?.categoryBitMask |= powerupCategory
								sprite.physicsBody?.contactTestBitMask |= heroCategory
							}

						case "death":
							if ensurePhysicsBody(sprite) {
								sprite.physicsBody?.categoryBitMask |= deathtrapCategory
								sprite.physicsBody?.collisionBitMask |= heroCategory
							}
							
						default:
							NSLog("Treating unknown accessory in sprite specifier as normal level item: \(accessory)")
							if ensurePhysicsBody(sprite) {
								sprite.physicsBody?.categoryBitMask |= levelItemCategory
								sprite.physicsBody?.collisionBitMask |= heroCategory
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
    
    public override func update(currentTime: CFTimeInterval) {
        
    }
    
    public override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        // only jump when steve is running
        if (steveTheSprite.heroState == HeroState.Run) {
            // touch to jump
            for touch: AnyObject in touches {
                steveTheSprite.physicsBody?.velocity = CGVector(dx: 0, dy: 50)
                steveTheSprite.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 400))
                steveTheSprite.heroState = HeroState.Jump
            }
        }
    }
    
    // Define physics world ground
    private func addGroundLevel() {
        let ground = SKSpriteNode(color: UIColor(white: 1.0, alpha: 0), size:CGSize(width: frame.size.width, height: 5))
        
        // The ground is at the bottom of our viewable area
        ground.position = CGPoint(x: frame.size.width * 0.5, y: self.viewableArea.origin.y)
        ground.physicsBody = SKPhysicsBody(rectangleOfSize: ground.size)
        ground.physicsBody?.dynamic = false
        ground.physicsBody?.categoryBitMask = groundCategory
        ground.physicsBody?.collisionBitMask = heroCategory
        self.addChild(ground)
        // add a wall to the left edge of view and detect if character runs into it
        let wall = SKSpriteNode(color: UIColor(white: 1.0, alpha: 0), size: CGSize(width: 5, height: frame.size.height))
        wall.position = CGPoint(x: self.viewableArea.origin.x, y: self.viewableArea.size.height/2)
        wall.physicsBody = SKPhysicsBody(rectangleOfSize: wall.size)
        wall.physicsBody?.dynamic = false
        wall.physicsBody?.categoryBitMask = groundCategory
        wall.physicsBody?.collisionBitMask = heroCategory
        self.addChild(wall)
    }
    
    func gameOverAction() {
        callbackAfter(0.5 as Float) {
            self.gameEnd(false)
        }
    }
    
    func steveDidColliadeWith(body: SKPhysicsBody) {
		if (body.categoryBitMask & powerupCategory) == powerupCategory {
			if body.node == nil {
				return
			}
            steveTheSprite.didGetPowerUp()
			body.node?.removeFromParent()
            starCountNode.addPoint()
            lifeLineNode.addLifeLine(0.1)
        }
		if (body.categoryBitMask & deathtrapCategory) == deathtrapCategory {
			if body.node == nil {
				return
			}
			steveTheSprite.die()
            gameOverAction()
			return
		}
		if (body.categoryBitMask & groundCategory) == groundCategory {
			if body.node == nil {
				return
			}
			steveTheSprite.die()
            gameOverAction()
			
			return
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
			return
        }
    }
	
    public func didBeginContact(contact: SKPhysicsContact) {
        if let steve = contact.bodyA.node as? HeroNode {
            steveDidColliadeWith(contact.bodyB)
        }
        if let steve = contact.bodyB.node as? HeroNode {
            steveDidColliadeWith(contact.bodyA)
        }
    }
    
    public func gameEnd(didWin:Bool) {
		// If we don't have a view, then a different scene has been presented.
		// This could be problematic, so we'll trap that condition here.
		if self.view == .None {
			return
		}
        
		SKNode.cleanupScene(self)
        if didWin {
            self.view?.presentScene(LevelFinishedScene())
            ScoreManager.saveScore(starCountNode.getPoints(), forLevel: currentLevel)
        } else {
            let gameOverScene = GameOverScene()
            gameOverScene.level = currentLevel
            self.view?.presentScene(gameOverScene)
        }
        
    }
}
