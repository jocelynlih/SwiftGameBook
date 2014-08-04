//
//  GameScene.swift
//  PencilAdventure
//
//  Created by Jocelyn Harrington on 7/29/14.
//  Copyright (c) 2014 backstopmedia. All rights reserved.
//

import SpriteKit

extension SKNode
{
	func getTransform() -> CGAffineTransform
	{
		// Transform the path as specified by the sprite
		//
		// Note the order of operations we want to happen are specified in reverse. We want to scale first,
		// then rotate, then translate. If we do these out of order, then we might rotate around a different
		// point (if we've already moved it) or scale the object in the wrong direction (if we've rotated it.)
		var xform = CGAffineTransformIdentity
		xform = CGAffineTransformTranslate(xform, position.x, position.y)
		xform = CGAffineTransformRotate(xform, -zRotation)
		xform = CGAffineTransformScale(xform, xScale, yScale)
		return xform
	}
}

extension SKShapeNode
{
	func log()
	{
		NSLog(" Name     : %@", name)
		NSLog(" Position : %@, %@", position.x, position.y)
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
	let sketchTexture = UIImage(named: "sketchTexture")
	let sketchName = "- SketchSprite -"

	// The scene has sketch sprites added, which are in front of each sprite. We then need to ensure that our
	// enemies and hero are in front of them (and their sketches). We'll play with these numbers as development
	// progresses to ensure that they are indeed in front. Here are some good defaults:
	let enemyZPosition: CGFloat = 30
	let playerZPosition: CGFloat = 90

	// Material properties for sketch rendering
	struct SketchMaterial
	{
		var lineDensity: CGFloat = 4 // lower numbers are more dense
		var minSegmentLength: CGFloat = 1
		var maxSegmentLength: CGFloat = 5
		var pixJitterDistance: CGFloat = 4
		var lineInteriorOverlapJitterDistance: CGFloat = 5
		var lineEndpointOverlapJitterDistance: CGFloat = 5
		var lineOffsetJitterDistance: CGFloat = 4
		var color: UIColor = UIColor.blackColor()
	}

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
		pencil.zPosition = playerZPosition
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
    func addGroundLevel() {
        let ground = SKSpriteNode(color: UIColor(white: 1.0, alpha: 0.0), size:CGSizeMake(frame.size.width, 5))
        ground.position = CGPointMake(frame.size.width/2,  0)
        ground.physicsBody = SKPhysicsBody(rectangleOfSize: ground.size)
        ground.physicsBody.dynamic = false
        self.addChild(ground)
    }
    
	// -------------------------------------------------------------------------------------------------------------------
	
	func attachSketchNodes(node: SKNode)
	{
		if !node.children
		{
			return
		}
		
		for child in node.children as [SKNode]
		{
			// Let's do depth-first traversal so that we don't end up traversing the children we're about to add
			attachSketchNodes(child)

			// We are only concerned with SKSpriteNodes
			if let sprite = child as? SKSpriteNode
			{
				if let name = sprite.name
				{
					// Don't sketch our sketches
					//
					// Since we're doing a depth-first traversal, this shouldn't be necessary, but it doesn't hurt
					// to be safe!
					if name == sketchName
					{
						continue
					}
					
					// Get the vectorized path for our bitmap
					if let pathArray = ImageTools.vectorizeImage(name: name)
					{
						// Create a new shape from the path and attach it to this sprite node
						if let sketchSprite = renderSketchSprite(pathArray, parent: sprite)
						{
							// Copy various properties from our parent
							sketchSprite.zPosition = sprite.zPosition + 1
							sketchSprite.color = sprite.color
							
							// TODO - need to understand why this works
							sketchSprite.xScale = sprite.size.width / sprite.texture.size().width / sprite.xScale
							sketchSprite.yScale = sprite.size.height / sprite.texture.size().height / sprite.yScale

							// Finally, make our sketch sprite a child of our parent sprite
							sprite.addChild(sketchSprite)
						}
					}
				}
			}
		}
	}

	func renderSketchSprite(pathArray: [[CGPoint]], parent: SKSpriteNode ) -> SKSpriteNode?
	{
		// Setup our material
		var material = SketchMaterial()
		material.color = parent.color
		
		var drawPath = UIBezierPath()
		
		for path in pathArray
		{
			var startPoint: CGVector? = nil
			var endPoint: CGVector? = nil

			for point in path
			{
				// Starting a new batch of lines?
				if !endPoint
				{
					endPoint = point.toCGVector()
					continue
				}
				else
				{
					startPoint = endPoint
					endPoint = point.toCGVector()
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
				var firstPoint = true
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
					
					// Add the segment
					if firstPoint
					{
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
						
						// Offset a little, perpendicular to the direction of the line
						segP0 += lineDirPerp * CGFloat.randomValueSigned(material.lineOffsetJitterDistance)
						
						drawPath.moveToPoint(segP0.toCGPoint())
						firstPoint = false
					}
					
					// Offset a little, perpendicular to the direction of the line
					segP1 += lineDirPerp * CGFloat.randomValueSigned(material.lineOffsetJitterDistance)

					// Draw the segment
					addPencilLineToPath(drawPath, startPoint: segP0, endPoint: segP1, material: material)
					
					// Track how much we've drawn so far
					lengthSoFar += segmentLength
				}
				
				startPoint = endPoint
			}
		}
		
		// We'll need a context to render our sketch into
		UIGraphicsBeginImageContext(parent.texture.size())
		var context = UIGraphicsGetCurrentContext()
		
		// Draw the sketch into our context
		CGContextSetStrokeColorWithColor(context, material.color.CGColor)
		drawPath.stroke()
		
		// Create a texture from our sketch context
		var texture = SKTexture(image: UIGraphicsGetImageFromCurrentImageContext())
		UIGraphicsEndImageContext()
		
		// Create a new sprite with this texture
		var newSprite = SKSpriteNode(texture: texture)
		
		// Set the name to something distinct so that we can recognize them in the chain
		newSprite.name = sketchName
		
		// Voila! Our new sketch sprite
		return newSprite
	}
	
	func addPencilLineToPath(path: UIBezierPath, startPoint: CGVector, endPoint: CGVector, material: SketchMaterial)
	{
		var lineVector = endPoint - startPoint
		var lineDir = lineVector.normal
		var lineLength = lineVector.length
		
		var p0 = startPoint
		while(true)
		{
			var p1 = p0 + lineDir * material.lineDensity
			
			path.moveToPoint(p0.randomOffset(material.pixJitterDistance).toCGPoint())
			path.addLineToPoint(p1.randomOffset(material.pixJitterDistance).toCGPoint())
			
			p0 = p1
			
			// Check our length
			if (p1 - startPoint).length >= lineLength
			{
				break
			}
		}
	}
}
