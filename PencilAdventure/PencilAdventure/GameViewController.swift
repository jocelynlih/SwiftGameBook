//
//  GameViewController.swift
//  PencilAdventure
//
//  Created by Jocelyn Harrington on 7/28/14.
//  Copyright (c) 2014 backstopmedia. All rights reserved.
//

import UIKit
import SceneKit
import SpriteKit


class GameViewController: UIViewController
{
	@IBOutlet weak var startGameButton: UIButton!
	
    var scene: GameScene!
	
    override func viewDidLoad()
	{
        super.viewDidLoad()
		
		// PDN - (07/30/2014) - Set up our SKView
		let skView = self.view as SKView
		skView.showsFPS = true
		skView.showsNodeCount = true
		skView.ignoresSiblingOrder = true
    }
	
    @IBAction func startGame(sender : AnyObject)
	{
		// PDN - (07/30/2014) - Just load a default file, GameScene.sks for now
		//
		// !TODO! - At some point, we should probably have a mechanism for choosing levels and
		// loading the appropriate one.
		scene = GameScene.unarchiveFromFile("GameScene") as? GameScene
		if scene
		{
			// Set the scale mode to scale to fit the window
			scene.scaleMode = .AspectFill
			
			let skView = self.view as SKView
			skView.presentScene(scene)
			
			// Hide the start button
			startGameButton.hidden = true
		}
    }
}
