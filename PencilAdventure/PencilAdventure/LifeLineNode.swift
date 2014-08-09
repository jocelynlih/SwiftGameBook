//
//  HUDNode.swift
//  PencilAdventure
//
//  Created by Ankur Patel on 8/7/14.
//  Copyright (c) 2014 backstopmedia. All rights reserved.
//

import SpriteKit

public protocol GameOverProtocol {
    func onGameOver()
}

public class LifeLineNode: SKCropNode {

    private var lifeLine: CGFloat = 1.0
    private var gameScene: GameScene?
    
    convenience init(forScene scene: GameScene) {
        self.init()
        
        gameScene = scene
        xScale = scene.getSceneScaleX()
        yScale = scene.getSceneScaleY()
        zPosition = 100
        
        // Start reducing led from the pencil
        callbackAfter(0.10, subtractPoints)
        
        let anchorPoint = CGPoint(x: 0, y: 0.5)
        let pencilSprite = SKSpriteNode(imageNamed: "pencil")
        pencilSprite.anchorPoint = anchorPoint
        addChild(pencilSprite)
        let mask = SKSpriteNode(color: SKColor.whiteColor().colorWithAlphaComponent(0.5), size: pencilSprite.size)
        mask.anchorPoint = CGPoint(x: 0, y: 0.5)
        maskNode = mask
        
        position = CGPointMake((scene.frame.width - pencilSprite.frame.width) / 2, scene.frame.height - (pencilSprite.frame.height * 3))
    }
    
    private func subtractPoints() {
        lifeLine -= 0.01
        self.maskNode.yScale = lifeLine
        if lifeLine > 0 {
            callbackAfter(0.1, subtractPoints)
        } else {
            gameScene?.onGameOver()
        }
    }
    
    public func addLifeLine(life: CGFloat) {
        // Give more led till Mr Pencil reaches the end
        if lifeLine < 1 {
            lifeLine += life
        }
        self.maskNode.yScale = lifeLine
    }
    
}
