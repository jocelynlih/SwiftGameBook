//
//  LevelSelectScene.swift
//  PencilAdventure
//
//  Created by Jocelyn Harrington on 8/3/14.
//  Copyright (c) 2014 backstopmedia. All rights reserved.
//

import SpriteKit

class LevelSelectScene : SKScene {
   
    override func didMoveToView(view: SKView) {
        self.backgroundColor = SKColor.whiteColor()
        let levelLabel = SKLabelNode(text: "Please choose a level")
        levelLabel.fontColor = SKColor.blueColor()
        levelLabel.position = CGPointMake(250.0, 250.0)
        self.addChild(levelLabel)
        addLevelSelectNode()
    }
    
    func addLevelSelectNode() {
        var startPosX:CGFloat = 60.0
        var startPosY:CGFloat = 200.0
        for i in 1...7 {
            let level = SKSpriteNode(imageNamed: "bluetile")
            level.name = "\(i)"
            level.position = CGPointMake(startPosX + (i*50), startPosY)
            self.addChild(level)
        }
    }
    
    func loadLevel(level: String) {
        NSLog("loading level")
        //TODO: create loading level animation
        let scene = GameScene.unarchiveFromFile(level) as? GameScene
        if scene {
            self.scene.view.presentScene(scene)
        }
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            let node = self.nodeAtPoint(location)
            let buttonName = node.name
            if buttonName == "1" {
            //TODO: add more levels
                loadLevel("1")
            } else {
                loadLevel("GameScene")
            }    
        }
    }
}
