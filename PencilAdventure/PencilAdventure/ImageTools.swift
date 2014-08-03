//
//  ImageTools.swift
//
//  Created by Paul Nettle on 8/1/14.
//

import SpriteKit

// Constants
let LeftNeighborMask = 0x01
let RightNeighborMask = 0x02
let TopNeighborMask = 0x04
let BottomNeighborMask = 0x08
let SelfAlphaMask = 0x10
let VisitedMask = 0x20

let AllNeighborMasks = LeftNeighborMask | RightNeighborMask | TopNeighborMask | BottomNeighborMask

// Constants
let AlphaComponentOffset = 3
let BytesPerPixel = 4

// While tracing edges, we use this tolerance to determine when to break the segment into multiple pieces
// Larger number means more error allowed, so there will be fewer segments making up the path
let EdgeAngleTolerance: CGFloat = 1.5
let AlphaThreshold: UInt8 = 128

var vectorizedShapes: [ String : [[CGPoint]] ] = [:]

class WritableCoordinate
{
	var x: CGFloat = 0
	var y: CGFloat = 0
	
	init(x: CGFloat, y: CGFloat)
	{
		self.x = x
		self.y = y
	}
}

class ImageTools
{
	// Find a "vertex neighbor" that is an "edge pixel"
	class func neighboringEdgePixel(imgMap: [UInt8], stride: Int, x: Int, y: Int) -> Point2D?
	{
		// These are our neighbors
		//
		// a b c
		// d   e
		// f g h
		
		let idx = y * stride + x
		let a = Int(imgMap[idx - 1 - stride])
		let b = Int(imgMap[idx     - stride])
		let c = Int(imgMap[idx + 1 - stride])
		
		let d = Int(imgMap[idx - 1])
		let e = Int(imgMap[idx + 1])
		
		let f = Int(imgMap[idx - 1 + stride])
		let g = Int(imgMap[idx     + stride])
		let h = Int(imgMap[idx + 1 + stride])
		
		if (e & SelfAlphaMask) != 0 && (e & AllNeighborMasks) != 0 && (e & AllNeighborMasks) != AllNeighborMasks && (e & VisitedMask) == 0
		{
			return Point2D(x: x+1, y: y)
		}
		if (h & SelfAlphaMask) != 0 && (h & AllNeighborMasks) != 0 && (h & AllNeighborMasks) != AllNeighborMasks && (h & VisitedMask) == 0
		{
			return Point2D(x: x+1, y: y+1)
		}
		if (g & SelfAlphaMask) != 0 && (g & AllNeighborMasks) != 0 && (g & AllNeighborMasks) != AllNeighborMasks && (g & VisitedMask) == 0
		{
			return Point2D(x: x, y: y+1)
		}
		if (f & SelfAlphaMask) != 0 && (f & AllNeighborMasks) != 0 && (f & AllNeighborMasks) != AllNeighborMasks && (f & VisitedMask) == 0
		{
			return Point2D(x: x-1, y: y+1)
		}
		if (d & SelfAlphaMask) != 0 && (d & AllNeighborMasks) != 0 && (d & AllNeighborMasks) != AllNeighborMasks && (d & VisitedMask) == 0
		{
			return Point2D(x: x-1, y: y)
		}
		if (a & SelfAlphaMask) != 0 && (a & AllNeighborMasks) != 0 && (a & AllNeighborMasks) != AllNeighborMasks && (a & VisitedMask) == 0
		{
			return Point2D(x: x-1, y: y-1)
		}
		if (b & SelfAlphaMask) != 0 && (b & AllNeighborMasks) != 0 && (b & AllNeighborMasks) != AllNeighborMasks && (b & VisitedMask) == 0
		{
			return Point2D(x: x, y: y-1)
		}
		if (c & SelfAlphaMask) != 0 && (c & AllNeighborMasks) != 0 && (c & AllNeighborMasks) != AllNeighborMasks && (c & VisitedMask) == 0
		{
			return Point2D(x: x+1, y: y-1)
		}
		
		return nil
	}

	// Returns an array of bytes containing the RGBA pixel data.
	// Each pixel is 4 bytes with one byte per color component.
	// Color components appear in [r, g, b, a] order
	// Each component is 8 bits (0-255)
	class func getBitmapBitsForImage(image: UIImage) -> [UInt8]
	{
		// Stride is the number of bytes in a single scanline.
		//
		// One of the purposes of stride is to account for padding to specific byte boundaries, but here, it's just the
		// width multiplied by the number of bytes per pixel.
		let width = Int(image.size.width)
		let height = Int(image.size.height)
		let stride = width * BytesPerPixel
		
		// Here is our bitmap array
		var data = [UInt8](count: height * stride, repeatedValue: UInt8(0))
		let colorSpace = CGColorSpaceCreateDeviceRGB()
		let bitmapInfo = CGBitmapInfo.fromRaw(CGImageAlphaInfo.PremultipliedLast.toRaw() | CGBitmapInfo.ByteOrderDefault.toRaw())
		let contextRef = CGBitmapContextCreate(&data, UInt(width), UInt(height), 8, UInt(stride), colorSpace, bitmapInfo!);
		let cgImage = image.CGImage;
		let rect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height);
		CGContextDrawImage(contextRef, rect, cgImage);
		
		return data
	}

	// Build a neighbor map
	class func getImageMap(image: [UInt8], width: Int, height: Int) -> [UInt8]
	{
		// We'll store our image map here
		var imgMap = [UInt8](count: width * height, repeatedValue: 0)
		
		// Scan the image and build our map
		//
		// Note that this process requires comparing pixels against their neighbors, edge pixels don't have neighbors, we
		// limit our range to [1 ..< n-1] for X and Y.
		for y in 1 ..< height-1
		{
			var lineIndex = y * width
			for x in 1 ..< width-1
			{
				var pixIndex = lineIndex + x
				
				if image[pixIndex * BytesPerPixel + AlphaComponentOffset] >= AlphaThreshold
				{
					imgMap[pixIndex] |= UInt8(SelfAlphaMask)
					imgMap[pixIndex - 1] |= UInt8(RightNeighborMask)
					imgMap[pixIndex + 1] |= UInt8(LeftNeighborMask)
					imgMap[pixIndex - width] |= UInt8(BottomNeighborMask)
					imgMap[pixIndex + width] |= UInt8(TopNeighborMask)
				}
			}
		}
		
		return imgMap
	}

	// Definitions:
	//
	// "Edge neighbor"   = Neighbor that shares an edge. These are pixel neighbors in the four primary directions
	//                     (up, down, left, right)
	// "Edge pixel"      = Any pixel that has an empty "Edge neighbor"
	// "Vertex neighbor" = Neighbor that shares a vertex. These are any of the eight neighbors (including corner
	//                     neighbors)
	class func vectorizeImage(image: UIImage, name: String? = nil) -> ([[CGPoint]])?
	{
		if (name)
		{
			// Get it from the cache
			var pathArray = vectorizedShapes[name!]
			
			// If we have it, return it
			if pathArray
			{
				return pathArray
			}
			
			// Not in the cache? Load it from a file
			pathArray = readPathArray(name!)

			// If it loaded, cache it and return it to our caller
			if pathArray
			{
				vectorizedShapes[name!] = pathArray
				return pathArray
			}
		}

		let w = Int(image.size.width)
		let h = Int(image.size.height)
		var imgData = getBitmapBitsForImage(image)
		var imgMap = getImageMap(imgData, width: w, height: h)
		var totalPoints = 1
		var pathArray: [[CGPoint]] = []
		
		while true
		{
			var pixCur: Point2D!
			
			pixSearchLoop:
			for y in 0 ..< h
			{
				var lineIndex = y * w
				for x in 0 ..< w
				{
					var pix = Int(imgMap[lineIndex + x])
					
					if (pix & SelfAlphaMask) != 0 && (pix & AllNeighborMasks) != 0 && (pix & AllNeighborMasks) != AllNeighborMasks && (pix & VisitedMask) == 0
					{
						// Keep track of the first one we find, this is where we'll start tracing the image
						if !pixCur
						{
							pixCur = Point2D(x: x, y: y)
							break pixSearchLoop
						}
					}
				}
			}
			
			// if we didn't find an edge pixel, there's no alpha in the entire image that's above our threshold
			if !pixCur
			{
				break
			}
			
			// Set this pixel as visited
			imgMap[pixCur.y * w + pixCur.x] |= UInt8(VisitedMask)
			
			// We'll use this vector as we trace around the edge to keep track of how much we bend around corners
			// so we'll know when it's time to create a new segment
			var vectorStart = pixCur.toCGVector()
			var vectorDir: CGVector? = nil
			var totalError: CGFloat = 0
			
			// We offset to the center
			var centerOffset = CGPoint(x: CGFloat(-w/2), y: CGFloat(-h/2))
			
			// Let's build a path around the perimeter of our image
			var path: [CGPoint] = [pixCur.toCGPoint() + centerOffset]
			
			while true
			{
				// Find the next pixel on the perimeter
				var pixPrev = pixCur
				pixCur = neighboringEdgePixel(imgMap, stride: w, x: pixCur.x, y: pixCur.y)
				
				// Did we reach the end of our edge?
				if !pixCur
				{
					// We should have more than one point in the path, otherwise, we're just going to add another
					// copy of our first point to this path (this would be a degenerate path)
					if (path.count > 1)
					{
						// Finish out the edge
						path += pixPrev.toCGPoint() + centerOffset
						totalPoints += 1
					}
					break
				}
				
				// Set this pixel as visited
				imgMap[pixCur.y * w + pixCur.x] |= UInt8(VisitedMask)
				
				// If this is our first neighbor along a new segment, start a new direction vector
				if !vectorDir
				{
					vectorDir = (pixCur.toCGVector() - vectorStart).normal
					continue
				}
				
				// Is the new pixel still on the current path segment (within tolerance?)
				var runningVector = (pixCur.toCGVector() - pixPrev.toCGVector()).normal
				totalError += 1 - runningVector.dot(vectorDir!)
				if totalError < EdgeAngleTolerance
				{
					// Nothing to do, keep looking for the end of the current segment
					continue
				}
				
				// Finish the current segment and start a new one
				totalPoints += 1
				path += pixPrev.toCGPoint() + centerOffset
				
				vectorStart = pixCur.toCGVector()
				vectorDir = nil
				totalError = 0
			}

			// Add our path to the array
			if path.count > 1
			{
				pathArray += path
			}
		}
		
		if (totalPoints == 0)
		{
			NSLog("vectorizedImage found no paths for [" + (name ? name!:"unnamed") + "]")
			return nil
		}
		
		NSLog("vectorized %d points for [" + (name ? name!:"unnamed") + "]", totalPoints)
		
		if (name)
		{
			vectorizedShapes[name!] = pathArray
			writePathArray(pathArray, name: name!)
		}
		
		return pathArray
	}
	
	class func writePathArray(pathArray: [[CGPoint]], name: String)
	{
		var pathArrayArr: [ [ [NSNumber] ] ] = []
		for path in pathArray
		{
			var pathArr: [ [NSNumber] ] = []
			for point in path
			{
				pathArr += [ NSNumber(float: Float(point.x)), NSNumber(float: Float(point.y)) ]
			}
			
			pathArrayArr += pathArr
		}

		let filename = name + ".vcache.plist"
		var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
		var documentsDirectoryPath = paths[0] as String
		var filePath = documentsDirectoryPath.stringByAppendingPathComponent(filename)
		if !pathArrayArr.bridgeToObjectiveC().writeToFile(filePath, atomically: true)
		{
			NSLog("Error writing plist file: " + filePath)
		}
	}
	
	class func readPathArray(name: String) -> ([[CGPoint]])?
	{
		let filename = name + ".vcache.plist"
		var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
		var documentsDirectoryPath = paths[0] as String
		var filePath = documentsDirectoryPath.stringByAppendingPathComponent(filename)
		let pathArrayArr = NSArray(contentsOfFile: filePath)
		if pathArrayArr == nil
		{
			return nil
		}

		var pathArray: [[CGPoint]] = []
		for arr in pathArrayArr as [ [ [NSNumber] ] ]
		{
			var path: [CGPoint] = []
			for value in arr as [ [NSNumber] ]
			{
				var x = CGFloat(value[0].floatValue)
				var y = CGFloat(value[1].floatValue)
				path += CGPoint(x: x, y: y)
			}
			
			pathArray += path
		}
		
		return pathArray
	}
}