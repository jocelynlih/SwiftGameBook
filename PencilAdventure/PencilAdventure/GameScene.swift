//
//  GameScene.swift
//  PencilAdventure
//
//  Created by Jocelyn Harrington on 7/29/14.
//  Copyright (c) 2014 backstopmedia. All rights reserved.
//

import SpriteKit

extension SKShapeNode
	{
	func log()
	{
		NSLog(" Name     : %@", name)
		NSLog(" Position : %@, %@", position.x, position.y)
		//NSLog(" Size     : %@, %@", size.width, size.height)
		NSLog(" Frame    : %@, %@ - %@ x %@", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height)
		NSLog(" Scale    : %@, %@", xScale, yScale)
		NSLog(" zRotation: %@", zRotation)
		NSLog(" zPosition: %@", zPosition)
	}
}

extension SKSpriteNode
{
	func log()
	{
		NSLog(" Name     : %@", name)
		NSLog(" Position : %@, %@", position.x, position.y)
		NSLog(" Size     : %@, %@", size.width, size.height)
		NSLog(" Frame    : %@, %@ - %@ x %@", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height)
		NSLog(" Scale    : %@, %@", xScale, yScale)
		NSLog(" zRotation: %@", zRotation)
		NSLog(" zPosition: %@", zPosition)
	}
}

class GameScene : SKScene, SKPhysicsContactDelegate
{	
	// We draw our sketches directly into this full-screen sprite
	var sketchSprite: SKSpriteNode!
	
	// Material properties for sketch rendering
	struct SketchMaterial
	{
		var lineDensity: CGFloat = 10 // lower numbers are more dense
		var minSegmentLength: CGFloat = 1
		var maxSegmentLength: CGFloat = 4
		var pixJitterDistance: CGFloat = 3
		var lineInteriorOverlapJitterDistance: CGFloat = 10
		var lineEndpointOverlapJitterDistance: CGFloat = 0
		var lineOffsetJitterDistance: CGFloat = 1
		var color: UIColor = UIColor.blackColor()
	}
	
    // bg layer
    var background:SKTexture!
    // moving action
    var moving:SKNode!
    // charater
    var pencil:SKSpriteNode!
    //category mask
    let pencilCategory: UInt32 = 1 << 0
    let platformCategory: UInt32 = 1 << 1
    let sharpenerCategory: UInt32 = 1 << 2
    
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
            //no need to move the bg now
            //moving.addChild(bgSprite)
        }
		
		// Give our root scene a name
		name = "SceneRroot"

		//create pencil
		pencil = SKSpriteNode(imageNamed: "pencil")
		//pencil.name = "pencil" // TODO: why does the outline for this guy not move with him when physics simulates him?
		pencil.physicsBody = SKPhysicsBody(rectangleOfSize: pencil.size)
		pencil.physicsBody.dynamic = true
        pencil.physicsBody.allowsRotation = false
        pencil.physicsBody.categoryBitMask = pencilCategory
        pencil.physicsBody.collisionBitMask = platformCategory | sharpenerCategory
        pencil.physicsBody.contactTestBitMask = sharpenerCategory
		pencil.color = UIColor(red: 1, green: 1, blue: 0, alpha: 1)
		pencil.position = CGPoint(x:frame.size.width/4, y:frame.size.height/2)
		pencil.zPosition = 1
		self.addChild(pencil)
		
		// Attach our sketch nodes to all sprites
		attachSketchNodes(self)
        
        //add ground level
        addGroundLevel()
        
        // Create a full-screen viewport
		sketchSprite = SKSpriteNode(color: UIColor(red: 0, green: 0, blue: 0, alpha: 0), size: frame.size)
		sketchSprite.position = CGPoint(x:frame.size.width/2, y:frame.size.height/2)
		self.addChild(sketchSprite)
	}
	
    func movingBgFromLevel(sprite: SKSpriteNode) {
        let scrollBgSprite = SKAction.moveByX(-sprite.texture.size().width * 2.0, y: 0, duration: NSTimeInterval(0.1 * sprite.texture.size().width * 2.0))
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
        let movePlatform = SKAction.moveByX(-distanceToMove, y:0.0, duration:NSTimeInterval(0.01 * distanceToMove))
        let removePlatform = SKAction.removeFromParent()
        let movePlatformAndRemove = SKAction.sequence([movePlatform, removePlatform])
        platform.runAction(movePlatformAndRemove)
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
				pencil.physicsBody.velocity = CGVector(dx: 0, dy: 500)
				pencil.physicsBody.applyImpulse(CGVector(dx: 0, dy: 1000))
				
            }
        }
    }
    
	override func didSimulatePhysics()
	{
		// Draw the scene
		renderScene()
	}
	
    //Define physics world ground
    func addGroundLevel() {
        let ground = SKSpriteNode(color: UIColor(white: 1.0, alpha: 0.0), size:CGSizeMake(frame.size.width, 5))
        ground.position = CGPointMake(frame.size.width/2,  0)
        ground.physicsBody = SKPhysicsBody(rectangleOfSize: ground.size)
        ground.physicsBody.dynamic = false
        self.addChild(ground)
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        if moving.speed > 0 {
            if ( contact.bodyA.categoryBitMask & sharpenerCategory ) == sharpenerCategory || ( contact.bodyB.categoryBitMask & sharpenerCategory ) == sharpenerCategory {
                //TODO: HUD display show character gets extra life
                NSLog("get extra life")
            }
        }
    }
    
	// -------------------------------------------------------------------------------------------------------------------
	
	func attachSketchNodes(node: SKNode)
	{
		for child in node.children as [SKNode]
		{
			// Let's do depth-first traversal so that we don't end up traversing the children we're about to add
			attachSketchNodes(child)

			// Attach shapes to sprites
			if let sprite = child as? SKSpriteNode
			{
				if let name = sprite.name
				{
					NSLog("Loading sprite: %@", name)
                    //moving platform and background
                    if name == "platform1" || name.hasPrefix("block") {
                        movingPlatformFromLevel(sprite)
                    } else if name.hasPrefix("cloud") || name.hasPrefix("shrubbery") {
                        movingBgFromLevel(sprite)
                    }
					let image = UIImage(named: name)
					if image != nil
					{
						if let path = ImageTools.vectorizeImage(image)
						{
							// Shapes that are children of sprites need to be scaled to the size of their parent
							//
							// Since our shape's path is stored at full-size, we need to scale our shape's path
							// by the ratio of its parent's size to its parent's texture size.
							var scale = CGPoint(x: 1, y: 1)
							scale.x = sprite.size.width / sprite.texture.size().width
							scale.y = sprite.size.height / sprite.texture.size().height
							
							// Create a new shape from the path and attach it to this sprite node
							var shape = SKShapeNode(path: path)
							shape.name = sprite.name + " (sketch)"
							shape.position = CGPoint(x:sprite.position.x, y: frame.size.height - sprite.position.y)
							shape.xScale = scale.x
							shape.yScale = scale.y
							shape.zRotation = sprite.zRotation
							shape.zPosition = sprite.zPosition
							shape.strokeColor = sprite.color
							sprite.addChild(shape)
						}
					}
				}
			}
		}
	}
	
	func renderScene()
	{
		NSLog("Render scene begin...")
		UIGraphicsBeginImageContext(frame.size)
		var ctx = UIGraphicsGetCurrentContext()

		renderNode(ctx, node: self)
		
		var textureImage = UIGraphicsGetImageFromCurrentImageContext()
		sketchSprite.texture = SKTexture(image: textureImage)
		
		UIGraphicsEndImageContext()
	}
	
	var indent = 0
	func renderNode(context: CGContext, node: SKNode)
	{
		for child in node.children as [SKNode]
		{
			// Create a material
			var m = SketchMaterial()
			var drawPath: CGPath? = nil
			
			if let shape = child as? SKShapeNode
			{
				// Set the color
				m.color = shape.strokeColor
				
				// Transform our path
				var xform = createNodeTransform(shape)
				if let path = CGPathCreateCopyByTransformingPath(shape.path, &xform)
				{
					// Get the path elements
					var elements = ConvertPath(path)
					
					// Draw it!
					drawPathToContext(context, pathElements: elements, material: m)
				}
			}
			
			// Recurse into the children
			renderNode(context, node: child)
		}
	}

	func createNodeTransform(node: SKNode) -> CGAffineTransform
	{
		// Transform the path as specified by the sprite
		//
		// Note the order of operations we want to happen are specified in reverse. We want to scale first,
		// then rotate, then translate. If we do these out of order, then we might rotate around a different
		// point (if we've already moved it) or scale the object in the wrong direction (if we've rotated it.)
		var xform = CGAffineTransformIdentity
		xform = CGAffineTransformTranslate(xform, node.position.x, node.position.y)
		xform = CGAffineTransformRotate(xform, -node.zRotation)
		xform = CGAffineTransformScale(xform, node.xScale, node.yScale)
		return xform
	}
	
	func drawPathToContext(context: CGContext, pathElements: NSArray!, material: SketchMaterial)
	{
		var path = UIBezierPath()
		path.lineWidth = 1
		
		var startPoint: CGVector? = nil
		var endPoint: CGVector? = nil
		for element in pathElements
		{
			// Starting a new batch of lines?
			if element.elementType == 0
			{
				startPoint = nil;
				endPoint = element.point.toCGVector()
				continue
			}
			else if element.elementType == 1 || element.elementType == 4
			{
				startPoint = endPoint
				endPoint = element.point.toCGVector()
			}
			
			// Make sure we have something to work with
			if startPoint == nil || endPoint == nil
			{
				continue
			}
			
			// The vector that defines our line
			var lineVector = endPoint! - startPoint!
			var lineDir = lineVector.normal
			var lineDirPerp = lineDir.perpendicular()
			
			// Line extension
			var lineP0 = startPoint! - lineDir * CGFloat.randomValue(material.lineEndpointOverlapJitterDistance)
			var lineP1 = endPoint! + lineDir * CGFloat.randomValue(material.lineEndpointOverlapJitterDistance)
			
			// Recalculate our line vector since it has changed
			lineVector = lineP1 - lineP0
			
			// Line length
			var lineLength = lineVector.length
			
			// Break the line up into segments
			var lengthSoFar: CGFloat = 0
			var done = false
			while lengthSoFar < lineLength && !done
			{
				// How far to draw for this segment?
				var segmentLength = material.minSegmentLength + CGFloat.randomValue(material.maxSegmentLength - material.minSegmentLength)
				
				// Don't go past the end of our line
				if segmentLength + lengthSoFar > lineLength
				{
					segmentLength = lineLength - lengthSoFar
					done = true
				}
				
				// Endpoints for this segment
				var segP0 = lineP0 + lineDir * lengthSoFar
				var segP1 = segP0 + lineDir * segmentLength
				
				// Add some overlap
				if lengthSoFar != 0
				{
					var overlap = CGFloat.randomValue(material.lineInteriorOverlapJitterDistance)
					
					// Our interior overlap might extend outside of our line, so we can check here to ensure
					// that doesn't happen
					if overlap > lengthSoFar
					{
						overlap = lengthSoFar
					}
					segP0 -= lineDir * overlap
				}
				
				// Offset them a little, perpendicular to the direction of the line
				segP0 += lineDirPerp * CGFloat.randomValueSigned(material.lineOffsetJitterDistance)
				segP1 += lineDirPerp * CGFloat.randomValueSigned(material.lineOffsetJitterDistance)
				
				// Draw the segment
				addPencilLineToPath(path, startPoint: segP0, endPoint: segP1, material: material)
				
				// Track how much we've drawn so far
				lengthSoFar += segmentLength
			}
			
			startPoint = endPoint
		}
		
		CGContextSetStrokeColorWithColor(context, material.color.CGColor)
		path.stroke()
	}
	
	func addPencilLineToPath(path: UIBezierPath, startPoint: CGVector, endPoint: CGVector, material: SketchMaterial)
	{
		var lineVector = endPoint - startPoint
		var lineLength = lineVector.length
		var lineLengthSquared = lineVector.lengthSquared
		var lineDir = lineVector.normal
		
		var density = material.lineDensity
		if density > lineLength
		{
			density = lineLength
		}
		
		var p0 = startPoint
		while(true)
		{
			var p1 = p0 + lineDir * density
			
			path.moveToPoint(p0.randomOffset(material.pixJitterDistance).toCGPoint())
			path.addLineToPoint(p1.randomOffset(material.pixJitterDistance).toCGPoint())
			
			p0 = p1
			
			// Check our length
			if (p1 - startPoint).lengthSquared >= lineLengthSquared
			{
				break
			}
		}
	}
}
