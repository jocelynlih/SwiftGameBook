//
//  GameViewController.swift
//  PencilAdventure
//
//  Created by Jocelyn Harrington on 7/28/14.
//  Copyright (c) 2014 backstopmedia. All rights reserved.
//

import SpriteKit

class GameViewController: UIViewController {

  @IBOutlet var startGameButton: UIButton!

  override func viewDidLoad() {
    super.viewDidLoad()

    // Setup our SpriteKit view.
		let view = self.view as SKView
//		view.showsFPS = true
//		view.showsNodeCount = true
//		view.ignoresSiblingOrder = true

    // Start the background music.
    SoundManager.playBackgroundMusic()
  }
	
  @IBAction func startGame (sender: AnyObject) {
    let view = self.view as SKView

    // Create and present our level scene.
    let levelScene = LevelSelectScene(size: CGSize(width: view.frame.width, height: view.frame.height))
    view.presentScene(levelScene)
		
    // We started the game, so hide the start game button.
    startGameButton.hidden = true
  }

}

