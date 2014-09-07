//
//  PaperScene.swift
//  PencilAdventure
//
//  Created by Paul Nettle on 8/26/14.
//  Copyright (c) 2014 backstopmedia. All rights reserved.
//

import SpriteKit
import GameKit

// The scene has sketch sprites added, which are in front of each sprite. We then need to ensure that our
// enemies and hero are in front of them (and their sketches). We'll play with these numbers as development
// progresses to ensure that they are indeed in front. Here are some good defaults:
//
// Note that these would normally be class properties, but Swift doesn't currently support class properties.
let SceneBackgroundZPosition: CGFloat = -20
let BackgroundZPosition: CGFloat = -10
let levelItemZPosition: CGFloat = 0
let EnemyZPosition: CGFloat = 30
let HeroZPosition: CGFloat = 90
let HUDZPosition: CGFloat = 100

public class PaperScene : SKScene {
    // Background layer
    private let BackgroundScrollSpeedUnitsPerSecond: CGFloat = 200
    private var background:SKTexture!
	
    // Our viewable area. This originates at the bottom/left corner and extends up/right in scene points.
    public var viewableArea: CGRect!
    
    // Sketch lines animation
    private let SketchAnimationFPS = 8.0
    private var sketchAnimationTimer: NSTimer?
    
    public override func didMoveToView(view: SKView) {
		super.didMoveToView(view)
		
		// Calculate our viewable area (in points)
		let viewToFrameScale = frame.width / view.frame.size.width
		viewableArea = CGRect()
		viewableArea.size.width = view.frame.size.width * viewToFrameScale
		viewableArea.size.height = view.frame.size.height * viewToFrameScale
		viewableArea.origin.x = (frame.size.width - viewableArea.size.width) / 2
		viewableArea.origin.y = (frame.size.height - viewableArea.size.height) / 2
		
		// Give our root scene a name
		name = "PaperSceneRoot"
	}
	
	public func setupBackground(scrolling: Bool) {
		// Our texture for the background
		let background = SKTexture(imageNamed: "paper")
		
		// Make it cheap to draw
		background.filteringMode = SKTextureFilteringMode.Nearest
		
		if scrolling {
			// Note that our background width uses 'frame.width'. This is because our scene is set to
			// AspectFill (and because we're a landscape game) SpriteKit will automatically scale everything
			// in the scene's viewport (including the background) to fill the screen horizontally. These
			// scaled dimensions are stored in 'SKScene.frame'.
			let backgroundWidth = frame.width
			
			// Our total scroll distance. We calculate this based on the width of the background sprite
			// which will be tiled backgroundTiles times. Note that we scroll one less than this to avoid
			// scrolling past the trailing edge of the last tile.
			let backgroundScrollDist = backgroundWidth
			let frameCenter = CGPoint(x: frame.width / 2.0, y: frame.height / 2.0)
			
			// Setup our parallax scrolling actions
			//
			// The speed is based on the distance we need to travel, the relative speed and the number of tiles we
			// have to cover. Doing this allows our speed to stay the same even if we change backgroundTileCount.
			let scrollTime = backgroundScrollDist / BackgroundScrollSpeedUnitsPerSecond
			let scrollBgSprite = SKAction.moveByX(-backgroundScrollDist, y: 0, duration: NSTimeInterval(scrollTime))
			let resetBgSprite = SKAction.moveByX(backgroundScrollDist, y: 0, duration: 0.0)
			let moveBgSpritesForever = SKAction.repeatActionForever(SKAction.sequence([scrollBgSprite,resetBgSprite]))
			
			// Finally we can add the background tiles. We use two so we always have coverage
			for i in 0 ..< 2 {
				let bgSprite = SKSpriteNode(texture: background)
				bgSprite.size = frame.size
				bgSprite.position = CGPoint(x: frame.size.width/2.0 + backgroundScrollDist * CGFloat(i), y: frame.size.height/2.0)
				bgSprite.zPosition = SceneBackgroundZPosition
				bgSprite.runAction(moveBgSpritesForever)
				addChild(bgSprite)
			}
		}
		else {
			let frameCenter = CGPoint(x: frame.width / 2.0, y: frame.height / 2.0)
			let bgSprite = SKSpriteNode(texture: background)
			bgSprite.size = frame.size
			bgSprite.position = CGPoint(x: frame.size.width/2.0, y: frame.size.height/2.0)
			bgSprite.zPosition = SceneBackgroundZPosition
			addChild(bgSprite)
		}
    }
	
    public func setupOutdoorBackground() {
        // Our texture for the outdoor background
        let background = SKTexture(imageNamed: "outdoorbackdrop")
        
        // Make it cheap to draw
        background.filteringMode = SKTextureFilteringMode.Nearest

        let frameCenter = CGPoint(x: frame.width / 2.0, y: frame.height / 2.0)
        let bgSprite = SKSpriteNode(texture: background)
        bgSprite.size = frame.size
        bgSprite.position = CGPoint(x: frame.size.width/2.0, y: frame.size.height/2.0)
        bgSprite.zPosition = SceneBackgroundZPosition
        addChild(bgSprite)
    }

    
	public func convertToSketch()
	{
		// Attach our sketch nodes to all sprites
		SketchRender.attachSketchNodes(self)
		
		// Setup a timer for the update
		sketchAnimationTimer = NSTimer.scheduledTimerWithTimeInterval(1.0 / SketchAnimationFPS, target: self, selector: Selector("sketchAnimationTimer:"), userInfo: nil, repeats: true)
	}
	
    private func scaleToFillScreenWithAspect(srcSize: CGSize, targetSize: CGSize) -> CGFloat {
        // Find the dimension that has to grow the most
        let deltaWidth = abs(targetSize.width - srcSize.width)
        let deltaHeight = abs(targetSize.height - srcSize.height)
        
        if deltaWidth > deltaHeight {
            return targetSize.width / srcSize.width
        } else {
            return targetSize.height / srcSize.height
        }
    }
	
    public override func update(currentTime: CFTimeInterval) {
        
    }
    
    func sketchAnimationTimer(timer: NSTimer) {
        animateSketchSprites(self)
    }
    
    private func animateSketchSprites(node: SKNode) {
        var sketchSprites: [SKSpriteNode] = []
        
        // Find our sketch sprites
        for child in node.children as [SKNode] {
            // Depth-first traversal
            //
            // Note that we don't bother to traverse into our sketch sprites
            if child.name != SketchName {
                animateSketchSprites(child)
            }
            
            if let sprite = child as? SKSpriteNode {
                // We need a name
                if let name = sprite.name {
                    if name == SketchName {
                        // If it's hidden, let's add it to our list of possible sprites to un-hide
                        if sprite.hidden {
                            sketchSprites.append(sprite)
                        } else {
                            // This is the one that's already been visible, so let's make sure we get a different one
                            // by not adding it to the list. We do, however, want to hide it.
                            sprite.hidden = true
                        }
                    }
                }
            }
        }
        
        // If we found a set of sketch sprites, then unhide just one of them
        if sketchSprites.count != 0 {
            let rnd = arc4random_uniform(UInt32(sketchSprites.count))
            sketchSprites[Int(rnd)].hidden = false
        }
    }
}
