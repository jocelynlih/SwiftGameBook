//
//  SketchRender.swift
//  PencilAdventure
//
//  Created by Paul Nettle on 8/3/14.
//  Copyright (c) 2014 backstopmedia. All rights reserved.
//

import SpriteKit

let SketchName = "- SketchSprite -"

// We create this many variants of a sketch sprite, which we will animate through (randomly). If we choose 1,
// we will get static animations. If we choose 2, we'll see a clear swapping animation. 3 will be better, but
// will produce a noticeable repeating pattern. Four seems like a good starting point.
let MaxAnimationSprites = 4

class SketchRender {
	
	// Material properties for sketch rendering
	internal struct SketchMaterial {
		var lineDensity: CGFloat = 1 // lower numbers are more dense
		var minSegmentLength: CGFloat = 10
		var maxSegmentLength: CGFloat = 35
		var pixJitterDistance: CGFloat = 3
		var lineInteriorOverlapJitterDistance: CGFloat = 35
		var lineEndpointOverlapJitterDistance: CGFloat = 5
		var lineOffsetJitterDistance: CGFloat = 4
		var color: UIColor = UIColor.blackColor()
//		var lineDensity: CGFloat = 2 // lower numbers are more dense
//		var minSegmentLength: CGFloat = 1
//		var maxSegmentLength: CGFloat = 15
//		var pixJitterDistance: CGFloat = 2
//		var lineInteriorOverlapJitterDistance: CGFloat = 5
//		var lineEndpointOverlapJitterDistance: CGFloat = 5
//		var lineOffsetJitterDistance: CGFloat = 0
//		var color: UIColor = UIColor.blackColor()
		
		init(scaled: Bool = true) {
			// Some properties need to take into account the backing scale (i.e. *2 for retina displays)
			// TODO: I'm not sure this is entirely correct. The iPhone looks pretty different from the retina ipad
			let scale = UIScreen.mainScreen().scale
			
			minSegmentLength *= scale
			maxSegmentLength *= scale
			pixJitterDistance *= scale
			lineInteriorOverlapJitterDistance *= scale
			lineEndpointOverlapJitterDistance *= scale
			lineOffsetJitterDistance *= scale
		}
	}
	
	internal class func attachSketchNodes(node: SKNode) {
		if !node.children {
			return
		}
		
		for child in node.children as [SKNode] {
			// Let's do depth-first traversal so that we don't end up traversing the children we're about to add
			attachSketchNodes(child)
			
			// We are only concerned with SKSpriteNodes
			if let sprite = child as? SKSpriteNode {
				if let name = sprite.name {
					// Don't sketch our sketches
					//
					// Since we're doing a depth-first traversal, this shouldn't be necessary, but it doesn't hurt
					// to be safe!
					if name == SketchName {
						continue
					}
					
					// !HACK! - At the present time, XCode's level designer forces us to select a specific resolution/density
					// for sprites, rather than specifying a generic name which is used to dynamically select the proper resolution/
					// density at run time. So we'll do that here...
					var img = UIImage(named: name)
					if img == .None {
						continue
					}
					sprite.texture = SKTexture(image: img)
					if sprite.texture == .None {
						NSLog("Unable to create texture from image for sprite named \(name)")
						continue
					}
					
					// TODO: We should cache sketches of similar sprites rather than create fresh copies for each.
					//       Example: three instances of "cloud1" will each create 4 brand new sketch sprites for a
					//       total of 12 new sprites. Ideally, each instance of "cloud1" should use the same four
					//       sketch sprites.
					//
					// Get the vectorized path for our bitmap
					if let pathArray = ImageTools.vectorizeImage(name: name, image: img) {
						for i in 0 ..< MaxAnimationSprites {
							// We'll need our image size (in pixels)
							let imageWidthPix = CGFloat(CGImageGetWidth(img.CGImage))
							let imageHeightPix = CGFloat(CGImageGetHeight(img.CGImage))
							var imageSize = CGSize(width: imageWidthPix, height: imageHeightPix)
							
							// Create a new shape from the path and attach it to this sprite node
							if let sketchSprite = renderSketchSprite(pathArray, size: imageSize, parent: sprite) {
								// Ensure we draw in front of our parent
								sketchSprite.zPosition = 1
								
								// We get our sketch color from our parent's color
								sketchSprite.color = sprite.color

								// Set our size to that of our parent, taking it's scale into account
								sketchSprite.size = CGSize(width: sprite.size.width / sprite.xScale, height: sprite.size.height / sprite.yScale)

								// All sketch sprites are hidden until we unhide them at random for animation
								sketchSprite.hidden = true
								
								// Finally, make our sketch sprite a child of our parent sprite
								sprite.addChild(sketchSprite)
							}
						}
					}
				}
			}
		}
	}
	
	private class func renderSketchSprite(pathArray: [[CGPoint]], size: CGSize, parent: SKSpriteNode ) -> SKSpriteNode? {
		if !parent.texture {
			return .None
		}
		
		// Setup our material
		var material = SketchMaterial()
		material.color = parent.color
		
		var drawPath = UIBezierPath()
		
		for path in pathArray {
			var startPoint: CGVector?
			var endPoint: CGVector?
			
			for point in path {
				// Starting a new batch of lines?
				if endPoint == .None {
					endPoint = point.toCGVector()
					continue
				}
				else {
					startPoint = endPoint
					endPoint = point.toCGVector()
				}
				
				// Make sure we have something to work with
				if startPoint == .None || endPoint == .None {
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
				while lengthSoFar < lineLength && !done {
					// How far to draw for this segment?
					var segmentLength = material.minSegmentLength + CGFloat.randomValue(material.maxSegmentLength - material.minSegmentLength)
					
					// Don't go past the end of our line
					if segmentLength + lengthSoFar > lineLength {
						segmentLength = lineLength - lengthSoFar
						done = true
					}
					
					// Endpoints for this segment
					var segP0 = lineP0 + lineDir * lengthSoFar
					var segP1 = segP0 + lineDir * segmentLength
					
					// Add the segment
					if firstPoint {
						// Add some overlap
						if lengthSoFar != 0 {
							var overlap = CGFloat.randomValue(material.lineInteriorOverlapJitterDistance)
							
							// Our interior overlap might extend outside of our line, so we can check here to ensure
							// that doesn't happen
							if overlap > lengthSoFar {
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
		UIGraphicsBeginImageContext(size)
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
		newSprite.name = SketchName
		
		// Voila! Our new sketch sprite
		return newSprite
	}
	
	private class func addPencilLineToPath(path: UIBezierPath, startPoint: CGVector, endPoint: CGVector, material: SketchMaterial) {
		var lineVector = endPoint - startPoint
		var lineDir = lineVector.normal
		var lineLength = lineVector.length
		
		var p0 = startPoint
		while(true) {
			var p1 = p0 + lineDir * material.lineDensity
			
			path.moveToPoint(p0.randomOffset(material.pixJitterDistance).toCGPoint())
			path.addLineToPoint(p1.randomOffset(material.pixJitterDistance).toCGPoint())
			
			p0 = p1
			
			// Check our length
			if (p1 - startPoint).length >= lineLength {
				break
			}
		}
	}
}
