//
//  LevelSelectScene.swift
//  PencilAdventure
//
//  Created by Jocelyn Harrington on 8/3/14.
//  Copyright (c) 2014 backstopmedia. All rights reserved.
//

import SpriteKit

class LevelSelectScene : SKScene {
  
  var progressLoader: ProgressLoaderNode! = nil
	let MaxLevels = 8
	
  override func didMoveToView(view: SKView) {
    self.backgroundColor = SKColor.whiteColor()
    addProgressLoaderNode()
    addLevelSelectNode()
  }
    
    func addLevelSelectNode() {
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
  
  
  func addProgressLoaderNode () {
    progressLoader = ProgressLoaderNode()
    progressLoader.position = CGPoint(x: view.frame.width / 2, y: view.frame.height / 2 + 100)
    progressLoader.setProgress(0)
    self.addChild(progressLoader)
  }
	
  func loadLevel(level: String) {
    var scene: GameScene? = nil
    var work: Array<(Void) -> (Void)> = []
    
    work.append({
      sleep(5)
      return
    })
    
    // Unarchive scene.
    work.append({
      scene = GameScene.unarchiveFromFile(level) as? GameScene
    })

    // Perform all the work and move the progress along
    var done: CGFloat = 0
    for job in work {
      done++
      progressLoader.setProgress(done / CGFloat(work.count))
      job()
    }

    // Present the loaded game scene.
    self.scene.view.presentScene(scene!)
  }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
      for touch: AnyObject in touches {
        let location = touch.locationInNode(self)
        let node = self.nodeAtPoint(location)
        var loaded = false
        if let buttonName = node.name {
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
