//
//  SKScene+Extensions.swift
//  PencilAdventure
//
//  Created by Paul Nettle on 8/6/14.
//  Copyright (c) 2014 backstopmedia. All rights reserved.
//

import SpriteKit

extension SKScene {
    
    // Our scene scale factor (to map it to the view)
    //
    // Any sprites we add to the scene need which aren't specifically sized to some dimension of the scene's
    // frame property will need to have their xScale/yScale multiplied by the sceneScale's width/height:
    func getSceneScale() -> CGSize {
        return CGSize(width: getSceneScaleX(), height: getSceneScaleY())
    }
    
    func getSceneScaleX() -> CGFloat {
        return frame.width / view!.frame.width
    }
    
    func getSceneScaleY() -> CGFloat {
        return frame.height / view!.frame.height
    }
}
