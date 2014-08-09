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
        
        let anchorPoint = CGPoint(x: 0, y: 0)
        let pencilSprite = SKSpriteNode(imageNamed: "pencil")
        pencilSprite.anchorPoint = anchorPoint
        addChild(pencilSprite)
        let mask = SKSpriteNode(color: SKColor.yellowColor(), size: pencilSprite.size)
        mask.anchorPoint = CGPoint(x: 0, y: 0)
        maskNode = mask
        
        position = CGPointMake(scene.frame.width - (pencilSprite.size.width * 3), scene.frame.height - (pencilSprite.size.height * 4))
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
        maskNode.yScale = lifeLine
    }
    
}
