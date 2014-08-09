//
//  StarCountNode.swift
//  PencilAdventure
//
//  Created by Ankur Patel on 8/9/14.
//  Copyright (c) 2014 backstopmedia. All rights reserved.
//

import SpriteKit

public class StarCountNode: SKLabelNode {
    
    private var points = 0
    private var gameScene: GameScene?
    
    convenience init(forScene scene: GameScene) {
        self.init(fontNamed: "Noteworthy")
        
        gameScene = scene
        text = String(points)
        fontColor = SKColor.darkGrayColor()
        xScale = scene.getSceneScaleX()
        yScale = scene.getSceneScaleY()
        position = CGPointMake(frame.width, scene.frame.height - (frame.height * 2))
        zPosition = 100
    }
    
    public func getPoints() -> Int {
        return points
    }
    
    public func addPoint() {
        // Give more led till Mr Pencil reaches the end
        points += 1
        text = String(points)
    }
    
}