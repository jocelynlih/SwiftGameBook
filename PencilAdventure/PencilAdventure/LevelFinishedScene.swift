//
//  LevelFinishedScene.swift
//  PencilAdventure
//
//  Created by Christoffer Hallas on 8/19/14.
//  Copyright (c) 2014 backstopmedia. All rights reserved.
//

import SpriteKit

class LevelFinishedScene: PaperScene {
  
  var level: Int?
  
  override func didMoveToView(view: SKView!) {
	super.didMoveToView(view)
		
	// Static paper background
	setupBackground(false)
		
    // Stop background music.
    SoundManager.stopBackgroundMusic()
    
    // Add a title.
    let titleLabel = SKLabelNode(text: "Level Finished!")
	titleLabel.fontColor = UIColor(red: 0.5, green: 0, blue: 0, alpha: 1)
    titleLabel.fontName = "Noteworthy"
    titleLabel.fontSize = 24
    titleLabel.position = CGPoint(x: 0.5, y: 0.7)
    titleLabel.xScale = getSceneScaleX()
    titleLabel.yScale = getSceneScaleY()
    addChild(titleLabel)

    if level != .None {
        let points = ScoreManager.getScoreForLevel(level!)
        if points != .None {
            // Add a score.
            let scoreLabel = SKLabelNode(text: "You scored \(points) points!")
			scoreLabel.fontColor = UIColor(red: 0, green: 0, blue: 0.5, alpha: 1)
            scoreLabel.fontName = "Noteworthy"
            scoreLabel.fontSize = 18
            scoreLabel.position = CGPoint(x: 0.5, y: 0.5)
            scoreLabel.xScale = getSceneScaleX()
            scoreLabel.yScale = getSceneScaleY()
            addChild(scoreLabel)
        }
    }
    
    // Add a back button button.
	let spriteAtlas = SKTextureAtlas(named: "Sprites")
	let backButton = SKSpriteNode(texture: spriteAtlas.textureNamed("ok"))
    backButton.name = "ok"
    backButton.position =  CGPoint(x: 0.5, y: 0.3)
    backButton.xScale = getSceneScaleX()
    backButton.yScale = getSceneScaleY()
    addChild(backButton)
  }
  
  override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
    for touch: AnyObject in touches {
      let node = self.nodeAtPoint(touch.locationInNode(self))
      if let buttonName = node.name {
        switch buttonName {
        case "ok":
		  SKNode.cleanupScene(self)
          view.presentScene(LevelSelectScene(size: CGSize(width: view.frame.width, height: view.frame.height)))
          break
        default: break
        }
      }
    }
  }
  
}
