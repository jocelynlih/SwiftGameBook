//
//  GameViewController.swift
//  PencilAdventure
//
//  Created by Jocelyn Harrington on 7/28/14.
//  Copyright (c) 2014 backstopmedia. All rights reserved.
//

import UIKit
import SpriteKit

// PDN - (07/30/2014) - added support to load scene files
extension SKNode
{
	class func unarchiveFromFile(file : NSString) -> SKNode?
	{
		let path = NSBundle.mainBundle().pathForResource(file, ofType: "sks")
		
		var sceneData = NSData.dataWithContentsOfFile(path, options: .DataReadingMappedIfSafe, error: nil)
		var archiver = NSKeyedUnarchiver(forReadingWithData: sceneData)
		
		archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
		let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as GameScene
		archiver.finishDecoding()
		return scene
	}
}

class GameViewController: UIViewController
{
	@IBOutlet weak var startGameButton: UIButton!
	
    var levelScene : LevelSelectScene!
    override func viewDidLoad() {
        super.viewDidLoad()
		
		// PDN - (07/30/2014) - Set up our SKView
		let skView = self.view as SKView
		skView.showsFPS = true
		skView.showsNodeCount = true
		skView.ignoresSiblingOrder = true
    }
	
    @IBAction func startGame(sender : AnyObject) {
        //load level select scene
			levelScene = LevelSelectScene(size: CGSizeMake(self.view.frame.width, self.view.frame.height))
			let skView = self.view as SKView
			skView.presentScene(levelScene)
			
			// Hide the start button
			startGameButton.hidden = true
		}
    }

