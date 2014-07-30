//
//  GameScene.swift
//  PencilAdventure
//
//  Created by Jocelyn Harrington on 7/29/14.
//  Copyright (c) 2014 backstopmedia. All rights reserved.
//

import SpriteKit

class GameScene : SKScene
{
	// At the moment, we only support boxes and lines.
	//
	// !TODO! - this should go away once we start to get our data from the level editor
	enum ObjectType
	{
		case Box
		case Line
	}
	
	// Material properties for sketch rendering
	//
	// !TODO! - These should be used as defaults, allowing a node's userData to contain keys that allow us to
	// override them to tweak values.
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
	
	// An object in our scene, consisting of its material, type (box/line) and points that define the object
	//
	// !TODO! this should be replaced with data from our level editor
	struct SceneObject
	{
		var material: SketchMaterial
		var type: ObjectType
		var point0: CGVector
		var point1: CGVector
	}
	
	var viewSprite: SKSpriteNode!
	
	override func didMoveToView(view: SKView)
	{
		// Create a full-screen viewport
		//
		// !TODO! - this should go away when we switch to rendering SKNode layers directly
		viewSprite = SKSpriteNode(color: UIColor(red: 0, green: 0, blue: 255, alpha: 0.2), size: frame.size)
		viewSprite.position = CGPoint(x:frame.size.width/2, y:frame.size.height/2)
		self.addChild(viewSprite)
	}
	
	override func update(currentTime: CFTimeInterval)
	{
		// Draw the scene
		//
		// !TODO! - this should go away when we switch to rendering SKNode layers directly
		renderScene()
	}
	
	// -------------------------------------------------------------------------------------------------------------------
	
	func renderScene()
	{
		UIGraphicsBeginImageContext(frame.size)
		var ctx = UIGraphicsGetCurrentContext()
		
		for child in children
		{
			var p0 = child.frame.origin.toCGVector()
			p0.dy = frame.size.height - p0.dy
			var p1 = p0 + CGVector(dx: child.frame.size.width, dy: -child.frame.size.height)
			var m = SketchMaterial()
			var obj = SceneObject(material: m, type: .Box, point0: p0, point1: p1)
			drawObjectToContext(ctx, object: obj)
		}
		
		var textureImage = UIGraphicsGetImageFromCurrentImageContext()
		viewSprite.texture = SKTexture(image: textureImage)
		
		UIGraphicsEndImageContext()
	}
	
	func getObjectLines(object: SceneObject) -> [CGVector]
	{
		var lines: [CGVector] = []
		switch object.type
		{
		case .Box:
			lines += object.point0
			lines += CGVector(dx: object.point1.dx, dy: object.point0.dy)
			lines += CGVector(dx: object.point1.dx, dy: object.point1.dy)
			lines += CGVector(dx: object.point0.dx, dy: object.point1.dy)
			lines += object.point0
			
		case .Line:
			lines += object.point0
			lines += object.point1
		}
		
		return lines
	}
	
	func drawObjectToContext(context: CGContext, object: SceneObject)
	{
		var lines = getObjectLines(object)
		
		var path = UIBezierPath()
		path.lineWidth = 1
		
		var startPoint = lines[0]
		for endPoint in lines[1 ..< lines.count]
		{
			// The vector that defines our line
			var lineVector = endPoint - startPoint
			var lineDir = lineVector.normal
			var lineDirPerp = lineDir.perpendicular()
			
			// Line extension
			var lineP0 = startPoint - lineDir * CGFloat.randomValue(object.material.lineEndpointOverlapJitterDistance)
			var lineP1 = endPoint + lineDir * CGFloat.randomValue(object.material.lineEndpointOverlapJitterDistance)
			
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
				var segmentLength = object.material.minSegmentLength + CGFloat.randomValue(object.material.maxSegmentLength - object.material.minSegmentLength)
				
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
					segP0 -= lineDir * CGFloat.randomValue(object.material.lineInteriorOverlapJitterDistance)
				}
				
				// Offset them a little, perpendicular to the direction of the line
				segP0 += lineDirPerp * CGFloat.randomValueSigned(object.material.lineOffsetJitterDistance)
				segP1 += lineDirPerp * CGFloat.randomValueSigned(object.material.lineOffsetJitterDistance)
				
				// Draw the segment
				addPencilLineToPath(path, startPoint: segP0, endPoint: segP1, material: object.material)
				
				// Track how much we've drawn so far
				lengthSoFar += segmentLength
			}
			
			startPoint = endPoint
		}
		
		CGContextSetStrokeColorWithColor(context, object.material.color.CGColor)
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
