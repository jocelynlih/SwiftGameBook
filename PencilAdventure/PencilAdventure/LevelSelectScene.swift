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
	var levelSelectSprite: SKSpriteNode!
	var levelSelectNodes = [SKSpriteNode]()
	
	override func didMoveToView(view: SKView) {
		super.didMoveToView(view)
		
		// Static paper background
		setupBackground(false)

        // Setup background music.
        SoundManager.toggleBackgroundMusic()
        
        // Add a middle layer.
        let chooseLevelImage = SKTexture(imageNamed: "ChooseLevel_HighScore_noPaper")
        
        chooseLevelImage.filteringMode = SKTextureFilteringMode.Nearest
        
        levelSelectSprite = SKSpriteNode(texture: chooseLevelImage)
        levelSelectSprite.size = frame.size
        levelSelectSprite.position = CGPoint(x: frame.size.width/2.0, y: frame.size.height/2.0)
        levelSelectSprite.zPosition = -1
		addChild(levelSelectSprite)
		
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
        
        var levelsToShow = 1
        for (key, value) in enumerate(ScoreManager.getScoreDict()) {
            if levelsToShow < MaxLevels {
                levelsToShow++
            }
        }
        
        // For every level, add a level selector.
        for i in 1...levelsToShow {
            var suffix = "enabled"
            
            // Create a level selector node and add it to
            // the scene.
			let levelTileName = "L\(i)-\(suffix)"
            let level = SKSpriteNode(texture: atlas.textureNamed(levelTileName))
            level.name = levelTileName
			level.color = UIColor.blackColor()
			if suffix == "disabled" {
				level.alpha = 0.3
			}
            level.position =  CGPoint(x: x, y: frame.height / 2)
            level.xScale = getSceneScaleX()
            level.yScale = getSceneScaleY()
            addChild(level)
            
			// Add it to the level select nodes that we hide when we start loading the level
			levelSelectNodes.append(level)
			
            // Move the x value over, as to not render two
            // nodes on top of each other.
            x += tileWidth + gap
        }
        
        // If high scores are available, display them
        // as a label node.
        if let highestScores = ScoreManager.getAllHighScores() {
            let highScoreLabel = SKLabelNode(text: "\(highestScores)")
            highScoreLabel.fontColor = SKColor.darkGrayColor()
            highScoreLabel.fontName = "Noteworthy"
            highScoreLabel.fontSize = 14
            highScoreLabel.position = CGPoint(x: view!.frame.width / 2, y: frame.height * 0.8 - highScoreLabel.frame.height)
            highScoreLabel.xScale = getSceneScaleX()
            highScoreLabel.yScale = getSceneScaleY()
            addChild(highScoreLabel)
        }
    }
    
    internal func addProgressLoaderNode () {
        progressLoader = ProgressLoaderNode(scene: self)
        progressLoader.position = levelSelectSprite.position
        progressLoader.setProgress(0)
        addChild(progressLoader)
		
		// Hide the level select nodes
		for node in levelSelectNodes {
			node.hidden = true
		}
		levelSelectSprite.alpha = 0.2
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
		var sketchNodes = 0
        
        // Add our progress to the scene
        addProgressLoaderNode()
        
		// Unarchive scene
		work.append {
			scene = GameScene.unarchiveFromFile(level) as? GameScene
		}
		
		// Prepare the level
		work.append {
			if scene != nil {
				// Give the scene access to the progress loader so it can update progress while it loads
				scene!.progressNode = self.progressLoader
				
				// Prepare the level, which takes time
				scene!.prepareLevel()
			}

			return scene
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
