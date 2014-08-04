//
//  SKNode+Extensions.swift
//  PencilAdventure
//
//  Created by Ankur Patel on 8/3/14.
//  Copyright (c) 2014 backstopmedia. All rights reserved.
//

import SpriteKit

extension SKNode
    {

    class func unarchiveFromFile(file : NSString) -> SKNode?
    {
        let path = NSBundle.mainBundle().pathForResource(file, ofType: "sks")
        
        var sceneData = NSData.dataWithContentsOfFile(path, options: .DataReadingMappedIfSafe, error: nil)
        var archiver = NSKeyedUnarchiver(forReadingWithData: sceneData)
        
        archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
        let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as GameScene
        archiver.finishDecoding()
        return scene
    }

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