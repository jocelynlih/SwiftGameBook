//
//  LevelSelectScene.swift
//  PencilAdventure
//
//  Created by Jocelyn Harrington on 8/3/14.
//  Copyright (c) 2014 backstopmedia. All rights reserved.
//

import SpriteKit

class LevelSelectScene : PaperScene {
    
    // Constants
    let MaxLevels = 4
	
    // Variables
    var progressLoader: ProgressLoaderNode!
    var isLoading = false
    
	override func didMoveToView(view: SKView) {
		super.didMoveToView(view)
		
		// Static paper background
		setupBackground(false)

        // Setup background music.
        SoundManager.toggleBackgroundMusic()
        
        // Add a title.
        let levelLabel = SKLabelNode(text: "Please choose a level")
        levelLabel.fontColor = SKColor.darkGrayColor()
        levelLabel.fontName = "Noteworthy"
        levelLabel.position = CGPoint(x: view.frame.width / 2, y: (view.frame.height / 2) + 50)
        levelLabel.xScale = getSceneScaleX()
        levelLabel.yScale = getSceneScaleY()
        addChild(levelLabel)
        
        // Add level select and high score nodes.
        addLevelSelectAndHighScoreNodes()
		
		// Let's draw our scene as a sketch
		convertToSketch()
    }
    
    internal func addLevelSelectAndHighScoreNodes () {
        // Load our our required resources.
        let atlas = SKTextureAtlas(named: "Levels")
        let levelTile = atlas.textureNamed("L1-enabled")
        
        // In order to create a grid for the level buttons,
        // we a tile width, height and a value for the gap
        // in between them.
        var tileWidth = levelTile.size().width
        var tileHeight = levelTile.size().height
        var gap = tileWidth / 2
        
        // We also need a selector width and an initial x
        // and y coordinate set.
        var selectorWidth = tileWidth * CGFloat(MaxLevels) + gap * CGFloat(MaxLevels - 1)
        var x = (view!.frame.width - selectorWidth) / 2 + tileWidth / 2
        var y = view!.frame.height / 2
        
        // For every level, add a level selector.
        for i in 1...MaxLevels {
            // The first two levels we statically enable,
            // while we leave the last two disabled.
            var suffix = "disabled"
            if !(i == 4) {
                suffix = "enabled"
            }
            
            // Create a level selector node and add it to
            // the scene.
			let levelTileName = "L\(i)-\(suffix)"
            let level = SKSpriteNode(texture: atlas.textureNamed(levelTileName))
            level.name = levelTileName
			level.color = UIColor.blackColor()
			if suffix == "disabled" {
				level.alpha = 0.3
			}
            level.position =  CGPoint(x: x, y: frame.height / 4)
            level.xScale = getSceneScaleX()
            level.yScale = getSceneScaleY()
            addChild(level)
            
            // Move the x value over, as to not render two
            // nodes on top of each other.
            x += tileWidth + gap
        }
        
        // If high scores are available, display them
        // as a label node.
        if let highestScores = ScoreManager.getAllHighScores() {
            let highScoreLabel = SKLabelNode(text: "High Score\n\(highestScores)")
            highScoreLabel.fontColor = SKColor.darkGrayColor()
            highScoreLabel.fontName = "Noteworthy"
            highScoreLabel.position = CGPoint(x: view!.frame.width / 2, y: y - highScoreLabel.frame.height)
            highScoreLabel.xScale = getSceneScaleX()
            highScoreLabel.yScale = getSceneScaleY()
            addChild(highScoreLabel)
        }
    }
    
    internal func addProgressLoaderNode () {
        progressLoader = ProgressLoaderNode(scene: self)
        progressLoader.position = CGPoint(x: view!.frame.width / 2, y: view!.frame.height / 2 + 100)
        progressLoader.setProgress(0)
        addChild(progressLoader)
    }
    
    internal func loadLevel(level: String) {
        // If we're already loading a level, disallow
        // other levels being loaded.
        if isLoading {
            NSLog("Avoiding interruptive load")
            return
        }
        isLoading = true
        
        var scene: GameScene? = nil
        var work: [Void -> Any?] = []
        
        // Add our progress to the scene
        addProgressLoaderNode()
        
        // Unarchive scene.
        work.append {
            scene = GameScene.unarchiveFromFile(level) as? GameScene
        }
        
        // Perform all the work and move the progress
        // along, this is done in the background as to
        // not block the main thread which renders the
        // scene.
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            var done = 0
            for job in work {
                done++
                job()
                self.progressLoader.setProgress(CGFloat(done) / CGFloat(work.count))
            }
            
            // Present our new scene
            dispatch_async(dispatch_get_main_queue()) {
                if let newScene = scene {
                    if let currentLevel = level.toInt() {
                        newScene.currentLevel = currentLevel
                    }
                    SKNode.cleanupScene(self)
                    self.view?.presentScene(newScene)
                    
                    // Restart the music as to play while the
                    // scene is loading.
                    SoundManager.restartBackgroundMusic()
                }
                else {
                    NSLog("The scene is nil!")
                }
                
                self.isLoading = false
            }
        }
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        for touch: AnyObject in touches {
            let node = self.nodeAtPoint(touch.locationInNode(self))
			if node.name == "L1-enabled" || node.parent?.name == "L1-enabled" {
				loadLevel("1")
			}
			if node.name == "L2-enabled" || node.parent?.name == "L2-enabled" {
				loadLevel("2")
			}
			if node.name == "L3-enabled" || node.parent?.name == "L3-enabled" {
				loadLevel("3")
			}
			if node.name == "L4-enabled" || node.parent?.name == "L4-enabled" {
				loadLevel("4")
			}
        }
    }
}
