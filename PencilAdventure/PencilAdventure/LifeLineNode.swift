//
//  HUDNode.swift
//  PencilAdventure
//
//  Created by Ankur Patel on 8/7/14.
//  Copyright (c) 2014 backstopmedia. All rights reserved.
//

import SpriteKit

public class LifeLineNode: SKCropNode {
    
    private var lifeLine: CGFloat = 1.0
    private var gameScene: GameScene?
    
    convenience init(forScene scene: GameScene) {
        self.init()
        
        gameScene = scene
        zPosition = HUDZPosition
        
        // Start reducing led from the pencil
        callbackAfter(0.10, subtractLifeLine)
        
        let healthSprite = SKSpriteNode(imageNamed: "health")
        healthSprite.xScale = scene.getSceneScaleX()
        healthSprite.yScale = scene.getSceneScaleY()
        addChild(healthSprite)
        
        // Position ourselves in the upper-right corner
        position.x = scene.viewableArea.origin.x + scene.viewableArea.size.width
        position.y = scene.viewableArea.origin.y + scene.viewableArea.size.height
        
        // Our sprite anchor is the center, so this means the center of the sprite is at the corner.
        // So let's move this away from the corner by half of it's size so it's just inside the screen
        position.x -= healthSprite.size.width/2
        position.y -= healthSprite.size.height/2
        
        // Let's also give it a small gap, relative to the size of the sprite (say... 1/8th?)
        position.x -= healthSprite.size.width/8
        position.y -= healthSprite.size.height/8
        
        // Create the maskNode
        maskNode = SKSpriteNode(color: SKColor.whiteColor(), size: healthSprite.size)
    }
    
    private func subtractLifeLine() {
        lifeLine -= 0.01
        maskNode.yScale = lifeLine
        if lifeLine > 0 {
            callbackAfter(0.1, subtractLifeLine)
        } else {
            gameScene?.onGameOver()
        }
    }
    
    public func addLifeLine(life: CGFloat) {
        // Give more led till Mr Pencil reaches the end
        if lifeLine < 1 {
            lifeLine += life
        }
        maskNode.yScale = lifeLine
    }
    
}
