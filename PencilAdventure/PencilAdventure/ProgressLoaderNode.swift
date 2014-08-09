//
//  ProgressLoaderNode.swift
//  PencilAdventure
//
//  Created by Christoffer Hallas on 8/6/14.
//  Copyright (c) 2014 backstopmedia. All rights reserved.
//

import SpriteKit

class ProgressLoaderNode: SKCropNode {

  required init(coder aDecoder: NSCoder!) {
    super.init(coder: aDecoder)
  }

  override init () {
    super.init()
    let anchorPoint = CGPoint(x: 0, y: 0.5)
    let loaderSprite = SKSpriteNode(imageNamed: "shrubbery1")
    loaderSprite.anchorPoint = anchorPoint
    self.addChild(loaderSprite)
    let mask = SKSpriteNode(color: SKColor.whiteColor(), size: loaderSprite.size)
    mask.anchorPoint = CGPoint(x: 0, y: 0.5)
    self.maskNode = mask
  }
  
  func setProgress (progress: CGFloat) {
    self.maskNode.xScale = progress
  }
  
}
