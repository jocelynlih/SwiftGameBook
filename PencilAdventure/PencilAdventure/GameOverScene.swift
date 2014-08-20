//
//  GameOverScene.swift
//  PencilAdventure
//
//  Created by Christoffer Hallas on 8/19/14.
//  Copyright (c) 2014 backstopmedia. All rights reserved.
//

import SpriteKit

class GameOverScene: SKScene {
  
  override func didMoveToView(view: SKView!) {
    super.didMoveToView(view)
    
    // Add a background.
    let backgroundColor = UIColor(red: 34/255, green: 189/255, blue: 217/255, alpha: 1.0)
    let backgroundTexture = SKSpriteNode(color: backgroundColor, size: frame.size)
    backgroundTexture.position = CGPointMake(frame.width / 2, frame.height / 2)
    addChild(backgroundTexture)
    
    // Add a title.
    let titleLabel = SKLabelNode(text: "Game Over!")
    titleLabel.fontColor = SKColor.whiteColor()
    titleLabel.fontName = "Noteworthy"
    titleLabel.fontSize = 20
    titleLabel.position = CGPoint(x: 0.5, y: 0.8)
    titleLabel.xScale = getSceneScaleX()
    titleLabel.yScale = getSceneScaleY()
    addChild(titleLabel)
  }
  
}
