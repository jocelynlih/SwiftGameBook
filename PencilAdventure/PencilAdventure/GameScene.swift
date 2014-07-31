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
	// Constants
	let BytesPerPixel = 4
	
	// We draw our sketches directly into this full-screen sprite
	var viewSprite: SKSpriteNode!
	
	// Material properties for sketch rendering
	struct SketchMaterial
	{
		var lineDensity: CGFloat = 3 // lower numbers are more dense
		var minSegmentLength: CGFloat = 3
		var maxSegmentLength: CGFloat = 4
		var pixJitterDistance: CGFloat = 1
		var lineInteriorOverlapJitterDistance: CGFloat = 1
		var lineEndpointOverlapJitterDistance: CGFloat = 1
		var lineOffsetJitterDistance: CGFloat = 1
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
        //create bg layer, use a bit of color feature for book demo purpose
        let background = SKTexture(imageNamed: "background")
        background.filteringMode = SKTextureFilteringMode.Nearest
        //parallax background
        let scrollBgSprite = SKAction.moveByX(-background.size().width * 2.0, y: 0, duration: NSTimeInterval(0.1 * background.size().width * 2.0))
        let resetBgSprite = SKAction.moveByX(background.size().width * 2.0, y: 0, duration: 0.0)
        let moveBgSpritesForever = SKAction.repeatActionForever(SKAction.sequence([scrollBgSprite,resetBgSprite]))
        
        for var i:CGFloat = 0; i < 2.0 + self.frame.size.width / ( background.size().width * 2.0 ); ++i {
            let bgSprite = SKSpriteNode(texture: background)
            bgSprite.setScale(2.0)
            bgSprite.color = SKColor(red: 255.0, green: 255.0, blue: 0.0, alpha: 1.0)
            bgSprite.colorBlendFactor = 0.7
            bgSprite.position = CGPointMake(bgSprite.size.width/2.0, bgSprite.size.height/2.0)
            bgSprite.zPosition = -1
            bgSprite.runAction(moveBgSpritesForever)
            moving.addChild(bgSprite)
        }
        
        //create pencil
        pencil = SKSpriteNode(imageNamed: "pencil")
        pencil.physicsBody = SKPhysicsBody(circleOfRadius: pencil.size.width / 2)
        pencil.physicsBody.dynamic = true
        pencil.position = CGPoint(x:frame.size.width/2, y:frame.size.height/2)
        self.addChild(pencil)
        
        //add ground level
        addGroundLevel()
        
		// Create a full-screen viewport
		viewSprite = SKSpriteNode(color: UIColor(red: 0, green: 0, blue: 255, alpha: 0.2), size: frame.size)
		viewSprite.position = CGPoint(x:frame.size.width/2, y:frame.size.height/2)
		self.addChild(viewSprite)
		
		// Load the level
		let levelImage = UIImage(named: "level.png")
		
		// Process the level image into nodes
		processLevelImage(levelImage)
	}
	
	override func update(currentTime: CFTimeInterval)
	{
		// Draw the scene
		renderScene()
        moving.speed = 1
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
    
    //Define physics world ground
    func addGroundLevel() {
        let ground = SKSpriteNode(color: UIColor(white: 1.0, alpha: 1.0), size:CGSizeMake(frame.size.width, 5))
        ground.position = CGPointMake(frame.size.width/2, 0)
        ground.physicsBody = SKPhysicsBody(rectangleOfSize: ground.size)
        ground.physicsBody.dynamic = false
        self.addChild(ground)
    }
    
	// -------------------------------------------------------------------------------------------------------------------

	// TODO: This routine probably needs a lot of error checking, especially if we're ever going to allow user-generated
	// content. It should, at a minimum, ensure the image is wider than it is tall, meets a minimum height value and
	// and has the proper bit depth/arrangement.
	func processLevelImage(img: UIImage)
	{
		let w = Int(img.size.width)
		let h = Int(img.size.height)
		
		// Stride is the number of bytes in a single scanline.
		//
		// One of the purposes of stride is to account for padding to specific byte boundaries, but here, it's just the
		// width multiplied by the number of bytes per pixel.
		let stride = w * BytesPerPixel
		
		var data = [UInt8](count: h * stride, repeatedValue: UInt8(0))
		let colorSpace = CGColorSpaceCreateDeviceRGB()
		let bitmapInfo = CGBitmapInfo.fromRaw(CGImageAlphaInfo.PremultipliedLast.toRaw() | CGBitmapInfo.ByteOrderDefault.toRaw())
		let contextRef = CGBitmapContextCreate(&data, UInt(w), UInt(h), 8, UInt(stride), colorSpace, bitmapInfo!);
		let cgImage = img.CGImage;
		let rect = CGRectMake(0, 0, CGFloat(w), CGFloat(h));
		CGContextDrawImage(contextRef, rect, cgImage);

		// The size of each block is based on the height ratio between the viewport and the image. The taller the image,
		// the higher the resolution, which will extend horizontally as well.
		//
		// The effective value we're calculating here, is the number of points per block
		let pointsPerBlock = frame.size.height / img.size.height
		
		// Start scannng that data
		for y in 0 ..< h
		{
			let scanlineIndex = (h-y-1) * stride
			for x in 0 ..< w
			{
				var pixIndex = scanlineIndex + x * BytesPerPixel
				var alpha = data[pixIndex+3]
				if alpha != 0
				{
					var cColor = integerColorAtIndex(data, index: pixIndex)
					var lColor = x == 0 ? cColor : integerColorAtIndex(data, index: pixIndex - BytesPerPixel)
					var rColor = x == w-1 ? cColor : integerColorAtIndex(data, index: pixIndex + BytesPerPixel)
					var tColor = y == 0 ? cColor : integerColorAtIndex(data, index: pixIndex + stride)
					var bColor = y == h-1 ? cColor : integerColorAtIndex(data, index: pixIndex - stride)
					
					let sx = CGFloat(x) * pointsPerBlock
					let sy = CGFloat(y) * pointsPerBlock
					let p0 = CGPoint(x: sx, y: sy)
					let p1 = CGPoint(x: CGFloat(sx) + pointsPerBlock, y: CGFloat(sy))
					let p2 = CGPoint(x: CGFloat(sx) + pointsPerBlock, y: CGFloat(sy) + pointsPerBlock)
					let p3 = CGPoint(x: CGFloat(sx), y: CGFloat(sy) + pointsPerBlock)
					
					var path = UIBezierPath()
					var found = false
					if (tColor&0xff000000) == 0
					{
						path.moveToPoint(p0)
						path.addLineToPoint(p1)
						found = true
					}
					if (rColor&0xff000000) == 0
					{
						path.moveToPoint(p1)
						path.addLineToPoint(p2)
						found = true
					}
					
					if cColor != bColor
					{
						path.moveToPoint(p2)
						path.addLineToPoint(p3)
						found = true
					}
					
					if cColor != lColor
					{
						path.moveToPoint(p3)
						path.addLineToPoint(p0)
						found = true
					}

					if (found)
					{
						var node = SKShapeNode(path: path.CGPath)
						node.strokeColor = colorAtIndex(data, index: pixIndex)
						node.hidden = true
						addChild(node)
					}
				}
			}
		}
	}

	func integerColorAtIndex(data: [UInt8], index: Int) -> UInt32
	{
		let r = UInt32(data[index+0])
		let g = UInt32(data[index+1])
		let b = UInt32(data[index+2])
		let a = UInt32(data[index+3])
		return (a<<24) | (r<<16) | (g<<8) | b
	}
	
	func colorAtIndex(data: [UInt8], index: Int) -> UIColor
	{
		let r = CGFloat(Int(data[index+0])) / 255
		let g = CGFloat(Int(data[index+1])) / 255
		let b = CGFloat(Int(data[index+2])) / 255
		let a = CGFloat(Int(data[index+3])) / 255
		return UIColor(red: r, green: g, blue: b, alpha: a)
	}

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
