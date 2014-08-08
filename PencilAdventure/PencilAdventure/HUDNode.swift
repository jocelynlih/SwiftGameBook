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

public class HUDNode: SKLabelNode {

    private var points = 10
    private var gameScene: GameScene?
    
    convenience init(forScene scene: GameScene) {
        self.init(fontNamed: "Helvetica")
        
        gameScene = scene
        text = String(points)
        fontColor = SKColor.blackColor()
        xScale = scene.getSceneScaleX()
        yScale = scene.getSceneScaleY()
        position = CGPointMake(scene.frame.width / 2, scene.frame.height - (frame.height * 2))
        zPosition = 100
        
        // Start reducing led from the pencil
        callbackAfter(0.10, subtractPoints)
    }
    
    private func subtractPoints() {
        points -= 1
        self.text = String(points)
        if points > 0 {
            callbackAfter(0.10, subtractPoints)
        } else {
            gameScene?.onGameOver()
        }
    }
    
    public func addPowerUpPoint(pts: Int) {
        // Give more led till Mr Pencil reaches the end
        points += pts
        text = String(points)
    }
    
}
