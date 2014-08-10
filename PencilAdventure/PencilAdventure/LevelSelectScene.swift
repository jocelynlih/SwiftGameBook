//
//  LevelSelectScene.swift
//  PencilAdventure
//
//  Created by Jocelyn Harrington on 8/3/14.
//  Copyright (c) 2014 backstopmedia. All rights reserved.
//

import SpriteKit

class LevelSelectScene : SKScene {
  
	private var progressLoader: ProgressLoaderNode!
	private let MaxLevels = 8
	
    override func didMoveToView(view: SKView) {
      scene.backgroundColor = UIColor.whiteColor()
      addLevelSelectNode()
    }
    
    internal func addLevelSelectNode() {
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
			level.xScale = getSceneScaleX()
			level.yScale = getSceneScaleY()
            self.addChild(level)
			
			x += tileWidth + gap
        }
		
		// TODO: SKLabelNode isn't available on iOS 7 - if we plan to support that, we might consider an alternative
		let levelLabel = SKLabelNode(text: "Please choose a level")
		levelLabel.fontColor = SKColor.darkGrayColor()
        levelLabel.fontName = "Noteworthy"
		levelLabel.position = CGPointMake(view.frame.width / 2, y + tileHeight * 3)
		levelLabel.xScale = getSceneScaleX()
		levelLabel.yScale = getSceneScaleY()
		self.addChild(levelLabel)
        
        if let highestScores = ScoreManager.getAllHighScores() {
            let highScoreLabel = SKLabelNode(text: "High Score\n\(highestScores)")

            highScoreLabel.fontColor = SKColor.darkGrayColor()
            highScoreLabel.fontName = "Noteworthy"
            highScoreLabel.position = CGPointMake(view.frame.width / 2, y - highScoreLabel.frame.height)
            highScoreLabel.xScale = getSceneScaleX()
            highScoreLabel.yScale = getSceneScaleY()
            addChild(highScoreLabel)
        }
    }
  
  
  internal func addProgressLoaderNode () {
	progressLoader = ProgressLoaderNode(scene: self)
    progressLoader.position = CGPoint(x: view.frame.width / 2, y: view.frame.height / 2 + 100)
    progressLoader.setProgress(0)
    addChild(progressLoader)
  }
	
  func loadLevel(level: String) {
    var scene: GameScene? = nil
    var work: [Void -> Any?] = []
    
    SoundManager.restartBackgroundMusic()
	
	// Add our progress to the scene
	addProgressLoaderNode()
	
    // Unarchive scene.
    work.append {
      scene = GameScene.unarchiveFromFile(level) as? GameScene
    }

    // Perform all the work and move the progress along, this is done in the background as to
    // not block the main thread which renders the scene
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
      var done = 0
      for job in work {
        done++
        self.progressLoader.setProgress(CGFloat(done) / CGFloat(work.count))
        job()
        if done == work.count {
          // Notify the main that that we're ready!
          dispatch_async(dispatch_get_main_queue()) {
            self.scene.view.presentScene(scene!)
          }
        }
      }
    }

  }

    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
      for touch: AnyObject in touches {
        let location = touch.locationInNode(self)
        let node = self.nodeAtPoint(location)
        var loaded = false
        if let buttonName = node.name {
			//TODO: add more levels
			if buttonName == "1" {
				loadLevel("1")
				loaded = true
			}
			if buttonName == "2" {
				loadLevel("2")
				loaded = true
			}
        }
        if !loaded {
          loadLevel("GameScene")
        }
      }
    }
}
