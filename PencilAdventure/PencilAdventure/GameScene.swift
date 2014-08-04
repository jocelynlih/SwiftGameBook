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

	// bg layer
    var background:SKTexture!
    // moving action
    var moving:SKNode!
    // charater
    var pencil:SKSpriteNode!
    
	override func didMoveToView(view: SKView)
	{
        // setup physics
		self.physicsWorld.gravity = CGVector(dx: 0.0, dy: -9.8 )
        self.physicsWorld.contactDelegate = self
        // add moving
        moving = SKNode()
        self.addChild(moving)
        //create bg layer, use a bit of color feature for book demo purpose
        let background = SKTexture(imageNamed: "background")
        background.filteringMode = SKTextureFilteringMode.Nearest
        //parallax background
        let scrollBgSprite = SKAction.moveByX(-background.size().width * 2.0, y: 0, duration: NSTimeInterval(0.1 * background.size().width * 2.0))
        let resetBgSprite = SKAction.moveByX(background.size().width * 2.0, y: 0, duration: 0.0)
        let moveBgSpritesForever = SKAction.repeatActionForever(SKAction.sequence([scrollBgSprite,resetBgSprite]))
        
        for var i:CGFloat = 0; i < 2.0 + self.frame.size.width / ( background.size().width * 2.0 ); ++i {
            let bgSprite = SKSpriteNode(texture: background)
            bgSprite.setScale(1.0)
            bgSprite.colorBlendFactor = 0.7
			bgSprite.position = CGPoint(x: bgSprite.size.width/2.0, y: bgSprite.size.height/2.0)
            bgSprite.zPosition = -10
            bgSprite.runAction(moveBgSpritesForever)
            moving.addChild(bgSprite)
        }
		
		// Give our root scene a name
		name = "SceneRroot"

		//create pencil
		pencil = SKSpriteNode(imageNamed: "pencil")
		pencil.name = "pencil"
		pencil.xScale = 0.5
		pencil.yScale = 0.5
		pencil.physicsBody = SKPhysicsBody(rectangleOfSize: pencil.size)
		pencil.physicsBody.dynamic = true
		pencil.color = UIColor(red: 1, green: 1, blue: 0, alpha: 1)
		pencil.position = CGPoint(x:frame.size.width/4, y:frame.size.height/2)
		pencil.zPosition = PlayerZPosition
		self.addChild(pencil)
		
		// Attach our sketch nodes to all sprites
		SketchRender.attachSketchNodes(self)
        
        //add ground level
        addGroundLevel()
	}
	
	override func update(currentTime: CFTimeInterval)
	{
        moving.speed = 1
	}
	
    //TODO: we can add more action later, to keep the demo simple, we use touch to jump for now
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        // touch to jump
        if moving.speed > 0  {
            for touch: AnyObject in touches {
                let location = touch.locationInNode(self)
				pencil.physicsBody.velocity = CGVector(dx: 0, dy: 50)
				pencil.physicsBody.applyImpulse(CGVector(dx: 0, dy: 400))
				
            }
        }
    }
    
    //Define physics world ground
    private func addGroundLevel() {
        let ground = SKSpriteNode(color: UIColor(white: 1.0, alpha: 0.0), size:CGSizeMake(frame.size.width, 5))
        ground.position = CGPointMake(frame.size.width/2,  0)
        ground.physicsBody = SKPhysicsBody(rectangleOfSize: ground.size)
        ground.physicsBody.dynamic = false
        self.addChild(ground)
    }
}
