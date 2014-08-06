//
//  GameScene.swift
//  PencilAdventure
//
//  Created by Jocelyn Harrington on 7/29/14.
//  Copyright (c) 2014 backstopmedia. All rights reserved.
//

import SpriteKit

class GameScene : SKScene, SKPhysicsContactDelegate
{
	// The scene has sketch sprites added, which are in front of each sprite. We then need to ensure that our
	// enemies and hero are in front of them (and their sketches). We'll play with these numbers as development
	// progresses to ensure that they are indeed in front. Here are some good defaults:
	private let EnemyZPosition: CGFloat = 30
	private let PlayerZPosition: CGFloat = 90

	// Background layer
	private let BackgroundScrollSpeed: CGFloat = 0.01
    private var background:SKTexture!
	
	// We'll place a series of horizontal background tiles into the scene that will get a parallax
	// scroll. Let's define some information about the number of tiles we'll scroll through and
	// their sizes.
	private let backgroundTileCount = 2
	
    // Category masks (including our hero, items that make up the level, etc.)
    private let heroCategory: UInt32 = 1 << 0
    private let levelCategory: UInt32 = 1 << 1
    private let sharpenerCategory: UInt32 = 1 << 2
	
	// Sketch lines animation
	private let SketchAnimationFPS = 8.0
	private var sketchAnimationTimer: NSTimer?
	
	// Steve (our hero)
	private var steveTheSprite: SKSpriteNode!
	private let SteveAnimationFPS = 25.0
	private let SteveMaxFrames = 12
	private let SteveTextureNameBase = "steve"
	private var steveAtlas: SKTextureAtlas?
	private var steveWalkingFrames = [SKTexture]()

	override func didMoveToView(view: SKView)
	{
        // Setup physics
		physicsWorld.gravity = CGVector(dx: 0.0, dy: -9.8 )
        physicsWorld.contactDelegate = self

        // Create the background layer sprite
        let background = SKTexture(imageNamed: "background")
			
		if background != .None {
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

			// Setup our parallax scrolling actions
			//
			// The speed is based on the distance we need to travel, the relative speed and the number of tiles we
			// have to cover. Doing this allows our speed to stay the same even if we change backgroundTileCount.
			let scrollTime = backgroundScrollDist * BackgroundScrollSpeed * CGFloat(backgroundTileCount)
			let scrollBgSprite = SKAction.moveByX(-backgroundScrollDist, y: 0, duration: NSTimeInterval(scrollTime))
			let resetBgSprite = SKAction.moveByX(backgroundScrollDist, y: 0, duration: 0.0)
			let moveBgSpritesForever = SKAction.repeatActionForever(SKAction.sequence([scrollBgSprite,resetBgSprite]))

			// Finally we can add the background tiles
			for i in 0 ..< backgroundTileCount {
				let bgSprite = SKSpriteNode(texture: background)
				bgSprite.size = frame.size
				bgSprite.position = CGPoint(x: frame.size.width/2.0 + backgroundScrollDist * CGFloat(i), y: frame.size.height/2.0)
				bgSprite.zPosition = -10
				bgSprite.runAction(moveBgSpritesForever)
				addChild(bgSprite)
			}
		}
		
		// Give our root scene a name
		name = "SceneRroot"

		// Create our hero
		steveAtlas = SKTextureAtlas(named: "Steve")
		if let atlas = steveAtlas {
			for i in 1 ... SteveMaxFrames {
				let texName = "\(SteveTextureNameBase)\(i)"
				if let texture = atlas.textureNamed(texName) {
					steveWalkingFrames.append(texture)
				}
			}
			
			steveTheSprite = SKSpriteNode(texture: steveWalkingFrames[0])
			steveTheSprite.name = "steve"
			steveTheSprite.xScale = getSceneScaleX()
			steveTheSprite.yScale = getSceneScaleY()
			steveTheSprite.physicsBody = SKPhysicsBody(rectangleOfSize: steveTheSprite.size)
			steveTheSprite.physicsBody.dynamic = true
			steveTheSprite.physicsBody.allowsRotation = false
			steveTheSprite.physicsBody.categoryBitMask = heroCategory
			steveTheSprite.physicsBody.collisionBitMask = levelCategory | sharpenerCategory
			steveTheSprite.physicsBody.mass = 0.3 // TODO - what to do about this?
			steveTheSprite.physicsBody.contactTestBitMask = sharpenerCategory
			steveTheSprite.position = CGPoint(x:frame.size.width/4, y:frame.size.height/2)
			steveTheSprite.zPosition = PlayerZPosition
			
			// (Steve is not a child, he's a 34-year old divorcee)
			addChild(steveTheSprite)

			// Run Steve, run!
			steveTheSprite.runAction(
				SKAction.repeatActionForever(
					SKAction.animateWithTextures(steveWalkingFrames, timePerFrame:1.0 / SteveAnimationFPS, resize:false, restore:false)
				), withKey:"steveRun"
			)
		}
		
		// Attach our sketch nodes to all sprites
		SketchRender.attachSketchNodes(self)
		
        //add ground level
        addGroundLevel()
		
		// Setup a timer for the update
		sketchAnimationTimer = NSTimer.scheduledTimerWithTimeInterval(1.0 / SketchAnimationFPS, target: self, selector: Selector("sketchAnimationTimer:"), userInfo: nil, repeats: true)
	}
	
	private func scaleToFillScreenWithAspect(srcSize: CGSize, targetSize: CGSize) -> CGFloat
	{
		// Find the dimension that has to grow the most
		let deltaWidth = abs(targetSize.width - srcSize.width)
		let deltaHeight = abs(targetSize.height - srcSize.height)
		
		if deltaWidth > deltaHeight
		{
			return targetSize.width / srcSize.width
		}
		else
		{
			return targetSize.height / srcSize.height
		}
	}
	
    func movingBgFromLevel(sprite: SKSpriteNode) {
        let scrollBgSprite = SKAction.moveByX(-sprite.texture.size().width * 2.0, y: 0, duration: NSTimeInterval(0.5 * sprite.texture.size().width * 2.0))
        let resetBgSprite = SKAction.moveByX(sprite.texture.size().width * 2.0, y: 0, duration: 0.0)
        let moveBgSpritesForever = SKAction.repeatActionForever(SKAction.sequence([scrollBgSprite,resetBgSprite]))
        
        for var i:CGFloat = 0; i < 2.0 + self.frame.size.width / ( sprite.texture.size().width * 2.0 ); ++i {
            sprite.runAction(moveBgSpritesForever)
        }
    }
    
    func movingPlatformFromLevel(sprite: SKSpriteNode) {
        //move the objects horizontally
        let platform = sprite
        let distanceToMove = CGFloat(self.frame.size.width + sprite.texture.size().width)
        let movePlatform = SKAction.moveByX(-distanceToMove, y:0.0, duration:NSTimeInterval(0.1 * distanceToMove))
        let removePlatform = SKAction.removeFromParent()
        let movePlatformAndRemove = SKAction.sequence([movePlatform, removePlatform])
        platform.runAction(movePlatformAndRemove)
    }
    
	override func update(currentTime: CFTimeInterval)
	{
	}
	
    //TODO: we can add more action later, to keep the demo simple, we use touch to jump for now
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        // touch to jump
		for touch: AnyObject in touches {
			let location = touch.locationInNode(self)
			steveTheSprite.physicsBody.velocity = CGVector(dx: 0, dy: 50)
			steveTheSprite.physicsBody.applyImpulse(CGVector(dx: 0, dy: 400))
        }
    }
    
    // Define physics world ground
    private func addGroundLevel() {
        let ground = SKSpriteNode(color: UIColor(white: 1.0, alpha: 0), size:CGSizeMake(frame.size.width, 5))
		
		// Find the ground (where our screen and view intersect at the bottom
		ground.position = CGPointMake(frame.width/2, (frame.height - view.frame.size.height) / 2 / getSceneScaleY())
        ground.physicsBody = SKPhysicsBody(rectangleOfSize: ground.size)
        ground.physicsBody.dynamic = false
        self.addChild(ground)
    }

    
    func didBeginContact(contact: SKPhysicsContact) {
		if ( contact.bodyA.categoryBitMask & sharpenerCategory ) == sharpenerCategory ||
			( contact.bodyB.categoryBitMask & sharpenerCategory ) == sharpenerCategory {
			//TODO: HUD display show character gets extra life
			NSLog("get extra life")
        }
    }
    
    func sketchAnimationTimer(timer: NSTimer)
    {
        animateSketchSprites(self)
    }
    
    private func animateSketchSprites(node: SKNode)
	{
		var sketchSprites: [SKSpriteNode] = []
		
		// Find our sketch sprites
		for child in node.children as [SKNode]
		{
			// Depth-first traversal
			//
			// Note that we don't bother to traverse into our sketch sprites
			if child.name != SketchName
			{
				animateSketchSprites(child)
			}

			if let sprite = child as? SKSpriteNode
			{
				// We need a name
				if let name = sprite.name
				{
					// TODO - this doesn't belong here - this is about animating the texture, not moving sprites
					// also, I don't think this always works because sprites sometimes don't have textures? [Investigate]
					if sprite.texture != .None {
						//moving platform and background
						if name == "platform1" || name.hasPrefix("block") {
							movingPlatformFromLevel(sprite)
						} else if name.hasPrefix("cloud") || name.hasPrefix("shrubbery") {
							movingBgFromLevel(sprite)
						}
					}
					
					if name == SketchName
					{
						// If it's hidden, let's add it to our list of possible sprites to un-hide
						if sprite.hidden
						{
							sketchSprites.append(sprite)
						}
						else
						{
							// This is the one that's already been visible, so let's make sure we get a different one
							// by not adding it to the list. We do, however, want to hide it.
							sprite.hidden = true
						}
					}
				}
			}
		}
		
		// If we found a set of sketch sprites, then unhide just one of them
		if sketchSprites.count != 0
		{
			let rnd = arc4random_uniform(UInt32(sketchSprites.count))
			sketchSprites[Int(rnd)].hidden = false
		}
	}
}
