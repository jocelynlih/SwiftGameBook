//
//  GameViewController.swift
//  PencilAdventure
//
//  Created by Jocelyn Harrington on 7/28/14.
//  Copyright (c) 2014 backstopmedia. All rights reserved.
//

import SpriteKit


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
        
        SoundManager.playBackgroundMusic()
    }
	
    @IBAction func startGame(sender : AnyObject) {
        //load level select scene
		levelScene = LevelSelectScene(size: CGSize(width: view.frame.width, height: view.frame.height))
		let skView = self.view as SKView
		skView.presentScene(levelScene)
		
		// Hide the start button
		startGameButton.hidden = true
	}
}

