//
//  SKNode+Extensions.swift
//  PencilAdventure
//
//  Created by Ankur Patel on 8/3/14.
//  Copyright (c) 2014 backstopmedia. All rights reserved.
//

import SpriteKit

extension SKNode {
    
    class func unarchiveFromFile(file : String) -> SKNode? {
        let path = NSBundle.mainBundle().pathForResource(file, ofType: "sks")
        
        let sceneData = NSData(contentsOfFile: path!, options: .DataReadingMappedIfSafe, error: nil)
        let archiver = NSKeyedUnarchiver(forReadingWithData: sceneData!)
        
        archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
        let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as GameScene
        archiver.finishDecoding()
        
        // Set the scene's scale mode to maintain aspect, but fill the screen (AspectFill)
        //
        // Since we're a landscape-only game the screen will always be wider than it is tall. AspectFill
        // will always end up filling the screen horizontally and cipping some graphics off the top/bottom
        // of the screen. We'll need to be careful not to put important stuff in those regions.
        scene.scaleMode = .AspectFill
        
        // Give it a modest background
        scene.backgroundColor = UIColor(red:0.2353, green:0.2353, blue:0.2353, alpha:1)
        
        return scene
    }
    
    func getTransform() -> CGAffineTransform {
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

	class func cleanupScene(node: SKNode) {
		for child in node.children as [SKNode] {
			cleanupScene(child)
		}
		node.removeFromParent()
	}
}