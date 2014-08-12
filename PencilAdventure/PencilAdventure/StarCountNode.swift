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
        zPosition = HUDZPosition
        
        // Position ourselves in the upper-left corner
        position.x = scene.viewableArea.origin.x
        position.y = scene.viewableArea.origin.y + scene.viewableArea.size.height
        
        // Let's move this away from the corner
        position.x += frame.size.width
        position.y -= frame.size.height
        
        // Let's also give it a small gap, relative to the size of the sprite (say... 1/8th?)
        position.x += frame.size.width/8
        position.y -= frame.size.height/8
        
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