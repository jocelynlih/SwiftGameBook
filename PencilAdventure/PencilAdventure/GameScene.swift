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
	// We draw our sketches directly into this full-screen sprite
	private var sketchSprite: SKSpriteNode!
	private let sketchTexture = UIImage(named: "sketchTexture")
	private let useTexture = true
	// Material properties for sketch rendering
	private struct SketchMaterial
	{
		var lineThickness: CGFloat = 3.0
		var minSegmentLength: CGFloat = 4
		var maxSegmentLength: CGFloat = 25
		var lineInteriorOverlapJitterDistance: CGFloat = 20
		var lineEndpointOverlapJitterDistance: CGFloat = 5
		var lineOffsetJitterDistance: CGFloat = 3
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
		//pencil.name = "pencil" // TODO: why does the outline for this guy not move with him when physics simulates him?
		pencil.physicsBody = SKPhysicsBody(rectangleOfSize: pencil.size)
		pencil.physicsBody.dynamic = true
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
		sketchScene()
	}
	
    //Define physics world ground
    private func addGroundLevel() {
        let ground = SKSpriteNode(color: UIColor(white: 1.0, alpha: 0.0), size:CGSizeMake(frame.size.width, 5))
        ground.position = CGPointMake(frame.size.width/2,  0)
        ground.physicsBody = SKPhysicsBody(rectangleOfSize: ground.size)
        ground.physicsBody.dynamic = false
        self.addChild(ground)
    }
    
	// -------------------------------------------------------------------------------------------------------------------
	
	private func attachSketchNodes(node: SKNode)
	{
		if !node.children
		{
			return
		}
		
		for child in node.children as [SKNode]
		{
			// Let's do depth-first traversal so that we don't end up traversing the children we're about to add
			attachSketchNodes(child)

			// Attach shapes to sprites
			if let sprite = child as? SKSpriteNode
			{
				if let name = sprite.name
				{
					let image = UIImage(named: name)
					if image != nil
					{
						if let pathArray = ImageTools.vectorizeImage(image, name: name)
						{
							// Shapes that are children of sprites need to be scaled to the size of their parent
							//
							// Since our shape's path is stored at full-size, we need to scale our shape's path
							// by the ratio of its parent's size to its parent's texture size.
							var scale = CGPoint(x: 1, y: 1)
							scale.x = sprite.size.width / sprite.texture.size().width
							scale.y = sprite.size.height / sprite.texture.size().height

							// Create a new shape from the path and attach it to this sprite node
							var shape = SKShapeNode()
							shape.name = sprite.name
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
	
	private func sketchScene()
	{
		UIGraphicsBeginImageContext(frame.size)
		var ctx = UIGraphicsGetCurrentContext()

		// Sketch the scene starting at the root node
		var m = SketchMaterial()
		sketchNode(ctx, node: self, material: m)

		if (useTexture)
		{
			// Texturize the sketches
			CGContextSetBlendMode(ctx, kCGBlendModeSourceIn)
			
			// Randomize the portion of the texture that we use each frame so that we don't get a static pattern
			var quarterWidth = sketchTexture.size.width / 4
			var quarterHeight = sketchTexture.size.height / 4
			var xOffset = CGFloat.randomValue(quarterWidth)
			var yOffset = CGFloat.randomValue(quarterHeight)
			var srcRect = CGRect(x: xOffset, y: yOffset, width: quarterWidth, height: quarterHeight)
			CGContextDrawTiledImage(ctx, srcRect, sketchTexture.CGImage)
		}
		
		// Set our sketch as the sketchSprite's texture
		var sketchOverlay = UIGraphicsGetImageFromCurrentImageContext()
		sketchSprite.texture = SKTexture(image: sketchOverlay)
		
		UIGraphicsEndImageContext()
	}
	
	private func sketchNode(context: CGContext, node: SKNode, var material: SketchMaterial)
	{
		for child in node.children as [SKNode]
		{
			if let shape = child as? SKShapeNode
			{
				if let pathArray = vectorizedShapes[shape.name]
				{
					// Set the color
					material.color = shape.strokeColor
					sketchPathToContext(context, pathArray: pathArray, xform: shape.getTransform(), material: material)
				}
			}

			// Recurse into the children
			sketchNode(context, node: child, material: material)
		}
	}

	
	private func sketchPathToContext(context: CGContext, pathArray: [[CGPoint]], var xform: CGAffineTransform, material: SketchMaterial)
	{
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

					drawPath.addLineToPoint(segP1.toCGPoint())
					
					// Track how much we've drawn so far
					lengthSoFar += segmentLength
				}
				
				startPoint = endPoint
			}
		}
		
		CGContextSetStrokeColorWithColor(context, material.color.CGColor)
		
		if let path = CGPathCreateCopyByTransformingPath(drawPath.CGPath, &xform)
		{
			drawPath = UIBezierPath(CGPath: path)
			drawPath.lineWidth = material.lineThickness
			drawPath.stroke()
		}
	}
}
