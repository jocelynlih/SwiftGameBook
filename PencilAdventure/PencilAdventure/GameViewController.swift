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
    override func viewDidLoad() {
        super.viewDidLoad()
		let skView = self.view as SKView
		skView.showsFPS = true
		skView.showsNodeCount = true
		skView.ignoresSiblingOrder = true
    }
	
    @IBAction func startGame(sender : AnyObject) {
        //load level select scene
		let gameScene = GameScene(size: CGSize(width: view.frame.width, height: view.frame.height))
		let skView = self.view as SKView
		skView.presentScene(gameScene)
		
		// Hide the start button
		startGameButton.hidden = true
	}
}

