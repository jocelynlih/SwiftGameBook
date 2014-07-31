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
	var viewSprite: SKSpriteNode!
	
	// Material properties for sketch rendering
	struct SketchMaterial
	{
		var lineDensity: CGFloat = 4 // lower numbers are more dense
		var minSegmentLength: CGFloat = 23
		var maxSegmentLength: CGFloat = 54
		var pixJitterDistance: CGFloat = 2
		var lineInteriorOverlapJitterDistance: CGFloat = 40
		var lineEndpointOverlapJitterDistance: CGFloat = 11
		var lineOffsetJitterDistance: CGFloat = 5
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
        self.physicsWorld.gravity = CGVectorMake( 0.0, -9.8 )
        self.physicsWorld.contactDelegate = self
        // add moving
        moving = SKNode()
        self.addChild(moving)
        //create bg layer
        let background = SKTexture(imageNamed: "background")
        background.filteringMode = SKTextureFilteringMode.Nearest
        let bgSprite = SKSpriteNode(texture: background)
        bgSprite.setScale(2.0)
        bgSprite.position = CGPointMake(bgSprite.size.width/2.0, bgSprite.size.height/2.0)
        bgSprite.zPosition = -1
        moving.addChild(bgSprite)
        //create pencil
        pencil = SKSpriteNode(imageNamed: "pencil")
        pencil.physicsBody = SKPhysicsBody(circleOfRadius: pencil.size.width / 2)
        pencil.physicsBody.dynamic = true
        pencil.position = CGPoint(x:frame.size.width/2, y:frame.size.height/2)
        self.addChild(pencil)
        
        
		// Create a full-screen viewport
		viewSprite = SKSpriteNode(color: UIColor(red: 0, green: 0, blue: 255, alpha: 0.2), size: frame.size)
		viewSprite.position = CGPoint(x:frame.size.width/2, y:frame.size.height/2)
		self.addChild(viewSprite)
	}
	
	override func update(currentTime: CFTimeInterval)
	{
		// Draw the scene
		renderScene()
	}
	
    //TODO: we can add more action later, to keep the demo simple, we use touch to jump for now
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        // touch to jump
        if moving.speed > 0  {
            for touch: AnyObject in touches {
                let location = touch.locationInNode(self)
                pencil.physicsBody.velocity = CGVectorMake(0, 1)
                pencil.physicsBody.applyImpulse(CGVectorMake(0, 10))
                
            }
        }
    }
    
	// -------------------------------------------------------------------------------------------------------------------

	func renderScene()
	{
		UIGraphicsBeginImageContext(frame.size)
		var ctx = UIGraphicsGetCurrentContext()
		
		// For convenience, flip the context's coordinate space
		CGContextScaleCTM(ctx, 1, -1)
		CGContextTranslateCTM(ctx, 0, -frame.size.height)
		
		for child in children
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
				drawPath = CGPathCreateCopyByTransformingPath(shape.path, &xform)
			}
			if let sprite = child as? SKSpriteNode
			{
				// Set the color
				m.color = sprite.color
				var r:CGFloat = 0
				var g:CGFloat = 0
				var b:CGFloat = 0
				var a:CGFloat = 0
				m.color.getRed(&r, green: &g, blue: &b, alpha: &a)
				m.color = UIColor(red: r, green: g, blue: b, alpha: 1)
				
				var xform = createNodeTransform(sprite)
				var rect = CGRectMake(-sprite.size.width / sprite.xScale / 2, -sprite.size.height / sprite.yScale / 2, sprite.size.width / sprite.xScale, sprite.size.height / sprite.yScale)
				drawPath = CGPathCreateWithRect(rect, &xform)
			}
			
			if let path = drawPath
			{
				// Get the path elements
				var elements = ConvertPath(path)
			
				// Draw it!
				drawPathToContext(ctx, pathElements: elements, material: m)
			}
		}
		
		var textureImage = UIGraphicsGetImageFromCurrentImageContext()
		viewSprite.texture = SKTexture(image: textureImage)
		
		UIGraphicsEndImageContext()
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
		xform = CGAffineTransformRotate(xform, node.zRotation)
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
					segP0 -= lineDir * CGFloat.randomValue(material.lineInteriorOverlapJitterDistance)
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
