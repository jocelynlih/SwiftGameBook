//
//  LevelSelectScene.swift
//  PencilAdventure
//
//  Created by Jocelyn Harrington on 8/3/14.
//  Copyright (c) 2014 backstopmedia. All rights reserved.
//

import SpriteKit

class LevelSelectScene : SKScene {
   
	let MaxLevels = 8
	
    override func didMoveToView(view: SKView) {
        self.backgroundColor = SKColor.whiteColor()
        addLevelSelectNode()
    }
    
    func addLevelSelectNode() {
        SoundManager.toggleBackgroundMusic()
		var atlas = SKTextureAtlas(named: "Sprites")
		var blueTile = atlas.textureNamed("bluetile")
		
		var tileWidth = blueTile.size().width
		var tileHeight = blueTile.size().height
		var gap = tileWidth * 2
		
		var selectorWidth = tileWidth * CGFloat(MaxLevels) + gap * CGFloat(MaxLevels - 1)
        var x = (view.frame.width - selectorWidth) / 2.0
        var y = view.frame.height / 2
        for i in 1...MaxLevels {
            let level = SKSpriteNode(texture: blueTile)
            level.name = "\(i)"
			level.position =  CGPoint(x: x, y: y)
            self.addChild(level)
			
			x += tileWidth + gap
        }
		
		let levelLabel = SKLabelNode(text: "Please choose a level")
		levelLabel.fontColor = SKColor.blueColor()
		levelLabel.position = CGPointMake(view.frame.width / 2, y + tileHeight * 3)
		self.addChild(levelLabel)
    }
	
    func loadLevel(level: String) {
        NSLog("loading level")
        //TODO: create loading level animation
        SoundManager.restartBackgroundMusic()
		if let newScene = GameScene.unarchiveFromFile(level) as? GameScene {
            self.scene.view.presentScene(newScene)
        }
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            let node = self.nodeAtPoint(location)
			var loaded = false
            if let buttonName = node.name
			{
				if buttonName == "1" {
					//TODO: add more levels
					loadLevel("1")
					loaded = true
				}
			}
			
			if !loaded {
				loadLevel("GameScene")
			}
        }
    }
}
