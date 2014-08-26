//
//  LevelFinishedScene.swift
//  PencilAdventure
//
//  Created by Christoffer Hallas on 8/19/14.
//  Copyright (c) 2014 backstopmedia. All rights reserved.
//

import SpriteKit

class LevelFinishedScene: SKScene {
  
  var level: Int?
  
  override func didMoveToView(view: SKView!) {
    super.didMoveToView(view)
    
    // Stop background music.
    SoundManager.stopBackgroundMusic()
    
    // Add a background.
    let backgroundColor = UIColor(red: 117/255, green: 233/255, blue: 94/255, alpha: 1.0)
    let backgroundTexture = SKSpriteNode(color: backgroundColor, size: frame.size)
    backgroundTexture.position = CGPointMake(0.5, 0.5)
    addChild(backgroundTexture)
    
    // Add a title.
    let titleLabel = SKLabelNode(text: "Level Finished!")
    titleLabel.fontColor = SKColor.whiteColor()
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
            scoreLabel.fontColor = SKColor.whiteColor()
            scoreLabel.fontName = "Noteworthy"
            scoreLabel.fontSize = 18
            scoreLabel.position = CGPoint(x: 0.5, y: 0.5)
            scoreLabel.xScale = getSceneScaleX()
            scoreLabel.yScale = getSceneScaleY()
            addChild(scoreLabel)
        }
    }
    
    // Add a back button button.
    let backButton = SKSpriteNode(imageNamed: "girlPicture")
    backButton.name = "backButton"
    backButton.position =  CGPoint(x: 0.3, y: 0.3)
    backButton.xScale = getSceneScaleX()
    backButton.yScale = getSceneScaleY()
    addChild(backButton)
  }
  
  override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
    for touch: AnyObject in touches {
      let node = self.nodeAtPoint(touch.locationInNode(self))
      if let buttonName = node.name {
        switch buttonName {
        case "backButton":
		  SKNode.cleanupScene(self)
          view.presentScene(LevelSelectScene(size: CGSize(width: view.frame.width, height: view.frame.height)))
          break
        default: break
        }
      }
    }
  }
  
}
