
import SpriteKit

// Force re-vectorization of these sprite names (ignoring any existing cache files)
//
// Example: [ "cloud1", "platform1" ]
let forceRevectorization: [String] = []
let disableCache = false

// Constants for our image map's edge flags
let EdgeMask = 0x1
let NoEdgeMask = 0x2
let VisitedMask = 0x4

// Color component access constants
let RedComponentOffset = 0
let GreenComponentOffset = 1
let BlueComponentOffset = 2
let AlphaComponentOffset = 3
let BytesPerPixel = 4

// While tracing edges, we use this tolerance to determine when to break the segment into multiple pieces
// Larger number means more error allowed, so there will be fewer segments making up the path
let EdgeAngleTolerance: CGFloat = 0.01
let MinPathLength = 5
let AlphaThreshold: UInt8 = 128
let ColorThreshold: Int32 = 50

var vectorizedShapes = [String :[[CGPoint]]]()

class WritableCoordinate {
  
  var x: CGFloat = 0
  var y: CGFloat = 0
  
  init(x: CGFloat, y: CGFloat) {
    self.x = x
    self.y = y
  }
  
}

class ImageTools {
  
  // Find a "vertex neighbor" that is an "edge pixel"
  class func neighboringEdgePixel(imgMap: [UInt8], stride: Int, x: Int, y: Int) -> Point2D? {
    // These are our neighbors
    //
    // a b c
    // d   e
    // f g h
    let idx = y * stride + x
    let e = Int(imgMap[idx + 1         ]);  if (e & EdgeMask) != 0 && (e & VisitedMask) == 0 { return Point2D(x: x+1, y: y+0) }
    let h = Int(imgMap[idx + 1 + stride]);  if (h & EdgeMask) != 0 && (h & VisitedMask) == 0 { return Point2D(x: x+1, y: y+1) }
    let g = Int(imgMap[idx     + stride]);  if (g & EdgeMask) != 0 && (g & VisitedMask) == 0 { return Point2D(x: x+0, y: y+1) }
    let f = Int(imgMap[idx - 1 + stride]);  if (f & EdgeMask) != 0 && (f & VisitedMask) == 0 { return Point2D(x: x-1, y: y+1) }
    let d = Int(imgMap[idx - 1         ]);  if (d & EdgeMask) != 0 && (d & VisitedMask) == 0 { return Point2D(x: x-1, y: y+0) }
    let a = Int(imgMap[idx - 1 - stride]);  if (a & EdgeMask) != 0 && (a & VisitedMask) == 0 { return Point2D(x: x-1, y: y-1) }
    let b = Int(imgMap[idx     - stride]);  if (b & EdgeMask) != 0 && (b & VisitedMask) == 0 { return Point2D(x: x+0, y: y-1) }
    let c = Int(imgMap[idx + 1 - stride]);  if (c & EdgeMask) != 0 && (c & VisitedMask) == 0 { return Point2D(x: x+1, y: y-1) }
    return nil
  }
  
  // Returns an array of bytes containing the RGBA pixel data.
  // Each pixel is 4 bytes with one byte per color component.
  // Color components appear in [r, g, b, a] order
  // Each component is 8 bits (0-255)
  class func getBitmapBitsForImage(image: UIImage) -> [UInt8] {
    // Our image width/height. We use CGImageGet* to get the actual pixel dimensions)
    let widthPix = Int(CGImageGetWidth(image.CGImage))
    let heightPix = Int(CGImageGetHeight(image.CGImage))
    
    // Stride is the number of bytes in a single scanline.
    //
    // One of the purposes of stride is to account for padding to specific byte boundaries, but here, it's just the
    // width multiplied by the number of bytes per pixel.
    let stride = widthPix * BytesPerPixel
    
    // Here is our bitmap array
    var data = [UInt8](count: heightPix * stride, repeatedValue: UInt8(0))
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedLast.rawValue | CGBitmapInfo.ByteOrderDefault.rawValue)
    let contextRef = CGBitmapContextCreate(&data, UInt(widthPix), UInt(heightPix), 8, UInt(stride), colorSpace, bitmapInfo);
    let cgImage = image.CGImage;
    let rect = CGRect(x: 0, y: 0, width: CGFloat(widthPix), height: CGFloat(heightPix));
    CGContextDrawImage(contextRef, rect, cgImage);
    
    return data
  }
  
  // Build a neighbor map
  class func getImageMap(image: [UInt8], widthPix: Int, heightPix: Int) -> [UInt8] {
    // We'll store our image map here
    var imgMap = [UInt8](count: widthPix * heightPix, repeatedValue: 0)
    
    // Scan the image and build our map
    //
    // Note that this process requires comparing pixels against their neighbors, edge pixels don't have neighbors, we
    // limit our range to [1 ..< n-1] for X and Y.
    for y in 1 ..< heightPix-1 {
      
      let lineIndex = y * widthPix
      for x in 1 ..< widthPix-1 {
        
        let pixIndex = lineIndex + x
        
        // If this pixel is forced not to be an edge (because a neighbor is) then skip it
        if (imgMap[pixIndex] & UInt8(NoEdgeMask)) != 0 {
          continue
        }
        
        // Get our RGB component so we can compare it against each of our neighbors
        let a = Int32(image[pixIndex * BytesPerPixel + AlphaComponentOffset])
        let r = a == 255 ? Int32(image[pixIndex * BytesPerPixel + RedComponentOffset]) : 0
        let g = a == 255 ? Int32(image[pixIndex * BytesPerPixel + GreenComponentOffset]) : 0
        let b = a == 255 ? Int32(image[pixIndex * BytesPerPixel + BlueComponentOffset]) : 0
        
        // When comparing color distances, we use this threshold. Note that we avoid the need to
        // sqrt() the distance because instead, we square our threshold.
        let colorThresholdSquared = ColorThreshold * ColorThreshold
        
        // Check our neighbors for an edge condition
        for offset in [1, widthPix, -1, -widthPix] {
          let neighborIndex = pixIndex + offset
          
          if (imgMap[neighborIndex] & UInt8(NoEdgeMask)) != 0 || (imgMap[neighborIndex] & UInt8(EdgeMask)) != 0 {
            continue
          }
          
          // Extract the color components of this neighbor
          let na = Int32(image[neighborIndex * BytesPerPixel + AlphaComponentOffset])
          let nr = na == 255 ? Int32(image[neighborIndex * BytesPerPixel + RedComponentOffset]) : 0
          let ng = na == 255 ? Int32(image[neighborIndex * BytesPerPixel + GreenComponentOffset]) : 0
          let nb = na == 255 ? Int32(image[neighborIndex * BytesPerPixel + BlueComponentOffset]) : 0
          
          // Calculate the color difference between the neighbor's RGB and the current pixel's RGB
          // using the 3D distance equation:
          let dr = nr - r
          let dg = ng - g
          let db = nb - b
          let distSquared = dr * dr + dg * dg + db * db
          
          // If the distance between the current pixel color and its neighbor's color is large
          // enough then we consider this an edge pixel
          if distSquared > colorThresholdSquared {
            imgMap[pixIndex] |= UInt8(EdgeMask)
            imgMap[neighborIndex] |= UInt8(NoEdgeMask)
            break
          }
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
  class func vectorizeImage(name: String? = nil, var image: UIImage? = nil) -> ([[CGPoint]])? {
    if name != .None {
      // Get it from the local cache in memory
      if let pathArray = vectorizedShapes[name!] {
        return pathArray
      }
      
      // We're going to check to see if we need to bother updating our vectorized path file.
      //
      // Our default is set to the disableCache flag (if we're disabling the cache, then we'll assume
      // that the file is automatically out-of-date.)
      var outOfDate = disableCache
      
      // If we haven't yet determined if it's out of date, check the actual timestamps now
      let fileManager = NSFileManager()
      let pathFilename = getPathArrayFilename(name!)
      if !outOfDate {
        if let pathFileCreationDate = fileManager.attributesOfItemAtPath(pathFilename, error: nil)?["NSFileModificationDate"] as? NSDate {
          let assetFilename = "\(NSBundle.mainBundle().bundlePath)/Assets.car"
          if let imageFolderCreationDate = fileManager.attributesOfItemAtPath(assetFilename, error: nil)?["NSFileModificationDate"] as? NSDate {
            // Is our path file older than the asset file?
            if imageFolderCreationDate.compare(pathFileCreationDate) == NSComparisonResult.OrderedDescending {
              // Our path file is out of date
              NSLog("Image determined to be out of date: \(name!)")
              outOfDate = true
            }
          }
        }
      }
      
      // If it's out of date, delete the vector path file so it can be regenerated
      if outOfDate {
        fileManager.removeItemAtPath(pathFilename, error: nil)
      }
        // Try to load the path file if it exists
      else if let pathArray = readPathArray(name!) {
        vectorizedShapes[name!] = pathArray
        return pathArray
      }
      
      // We'll need to generate one from the named image, so load the image if it wasn't provided
      if image == .None {
        image = UIImage(named: name!)
      }
    }
    
    // If we don't have an image at this point, we can't continue
    if image == .None {
      return nil
    }
    
    let widthPix = Int(CGImageGetWidth(image!.CGImage))
    let heightPix = Int(CGImageGetHeight(image!.CGImage))
    var imgData = getBitmapBitsForImage(image!)
    var imgMap = getImageMap(imgData, widthPix: widthPix, heightPix: heightPix)
    var totalPoints = 1
    var pathArray: [[CGPoint]] = []
    
    while true {
      var pixCur: Point2D!
      
      pixSearchLoop:
        for y in 0 ..< heightPix {
          var lineIndex = y * widthPix
          for x in 0 ..< widthPix {
            var pix = Int(imgMap[lineIndex + x])
            
            if (pix & EdgeMask) != 0 && (pix & VisitedMask) == 0 {
              // Keep track of the first one we find, this is where we'll start tracing the image
              pixCur = Point2D(x: x, y: y)
              break pixSearchLoop
            }
          }
      }
      
      // if we didn't find an edge pixel, there's no alpha in the entire image that's above our threshold
      if pixCur == nil {
        break
      }
      
      // Set this pixel as visited
      imgMap[pixCur.y * widthPix + pixCur.x] |= UInt8(VisitedMask)
      
      // We'll use this vector as we trace around the edge to keep track of how much we bend around corners
      // so we'll know when it's time to create a new segment
      var vectorStart = pixCur.toCGVector()
      var vectorDir = CGVector.zeroVector
      var totalError: CGFloat = 0
      
      // Let's build a path around the perimeter of our image
      //
      // Initialize our path (just an array of points) with our first pixel point
      var path = [pixCur.toCGPoint()]
      totalPoints += 1
      
      var visitedCount = 0
      
      while true {
        // Find the next pixel on the perimeter
        var pixPrev = pixCur
        pixCur = neighboringEdgePixel(imgMap, stride: widthPix, x: pixCur.x, y: pixCur.y)
        
        // Did we reach the end of our edge?
        if pixCur == nil {
          // If we visited any pixels at all, then add the last point
          if visitedCount != 0 {
            path.append(pixPrev.toCGPoint())
            totalPoints += 1
          }
          break
        }
        
        // Set this pixel as visited
        imgMap[pixCur.y * widthPix + pixCur.x] |= UInt8(VisitedMask)
        visitedCount++
        
        // If this is our first neighbor along a new segment, start a new direction vector
        if visitedCount == MinPathLength {
          vectorDir = (pixCur.toCGVector() - vectorStart).normal
        }
          // If we haven't traversed a minimum distance, just keep going
        else if visitedCount < MinPathLength {
          continue
        }
        
        // Is the new pixel still on the current path segment (within tolerance?)
        var runningVector = (pixCur.toCGVector() - vectorStart).normal
        totalError += 1 - runningVector.dot(vectorDir)
        if totalError < EdgeAngleTolerance {
          // Nothing to do, keep looking for the end of the current segment
          continue
        }
        
        // Finish the current segment and start a new one
        path.append(pixPrev.toCGPoint())
        totalPoints += 1
        
        vectorStart = pixCur.toCGVector()
        // We set the visited count to 1 because we terminated the current segment with pixPrev, which
        // means we've visited at least one pixel (pixCur) so far
        visitedCount = 1
        totalError = 0
      }
      
      // If our path has more than a single point, add it to the path array
      if path.count > 1 {
        pathArray.append(path)
      }
    }
    
    if totalPoints == 0 {
      NSLog("vectorizedImage found no paths for [" + (name ?? "unnamed") + "]")
      return .None
    }
    
    NSLog("vectorized %d points in %d paths for [" + (name ?? "unnamed") + "]", totalPoints, pathArray.count)
    
    if name != .None {
      vectorizedShapes[name!] = pathArray
      writePathArray(pathArray, name: name!)
    }
    
    return pathArray
  }
  
  class func writePathArray(pathArray: [[CGPoint]], name: String) {
    var pathArrayArr: [ [ [NSNumber] ] ] = []
    for path in pathArray {
      var pathArr: [ [NSNumber] ] = []
      for point in path {
        pathArr.append([ NSNumber(float: Float(point.x)), NSNumber(float: Float(point.y)) ])
      }
      
      pathArrayArr.append(pathArr)
    }
    
    let filename = name + ".vcache.plist"
    var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
    var documentsDirectoryPath = paths[0] as String
    var filePath = documentsDirectoryPath.stringByAppendingPathComponent(filename)
    
    if !pathArrayArr._bridgeToObjectiveC().writeToFile(filePath, atomically: true) {
      NSLog("Error writing plist file: " + filePath)
    }
  }
  
  class func getPathArrayFilename(name: String) -> String {
    let filename = name + ".vcache.plist"
    var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
    var documentsDirectoryPath = paths[0] as String
    return documentsDirectoryPath.stringByAppendingPathComponent(filename)
  }
  
  class func readPathArray(name: String) -> ([[CGPoint]])? {
    for forceEntry in forceRevectorization {
      if forceEntry == name {
        return .None
      }
    }
    
    let filePath = getPathArrayFilename(name)
    let pathArrayArr = NSArray(contentsOfFile: filePath)
    if pathArrayArr == .None || pathArrayArr?.count == 0 {
      return .None
    }
    
    var pathArray: [[CGPoint]] = []
    for arr in pathArrayArr as [ [ [NSNumber] ] ] {
      var path: [CGPoint] = []
      for value in arr as [ [NSNumber] ] {
        var x = CGFloat(value[0].floatValue)
        var y = CGFloat(value[1].floatValue)
        path.append(CGPoint(x: x, y: y))
      }
      
      pathArray.append(path)
    }
    
    return pathArray
  }

}