//
//  HomeScene.swift
//  PencilAdventure
//
//  Created by Jocelyn Harrington on 8/28/14.
//  Copyright (c) 2014 backstopmedia. All rights reserved.
//

import SpriteKit

class HomeScene : PaperScene {
 
    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
        
        // Static paper background
        setupBackground(false)
        
        // Add Steve
        let steve = HeroNode(scene: self, withPhysicsBody: false)
        steve.xScale = getSceneScaleX() * 2;
        steve.yScale = getSceneScaleY() * 2;
        if let scene = scene {
            steve.position = CGPoint(x: scene.frame.size.width * 0.2, y: scene.frame.size.height * 0.7)
            let moveSprite = SKAction.moveByX(scene.frame.size.width, y: 0, duration: 5.0)
            let resetSprite = SKAction.moveToX(0.0, duration: 0.0)
            let moveSpritesForever = SKAction.repeatActionForever(SKAction.sequence([moveSprite,resetSprite]))
            steve.runAction(moveSpritesForever)
            addChild(steve)
        }
    }


}