//
//  GameViewController.swift
//  PencilAdventure
//
//  Created by Jocelyn Harrington on 7/28/14.
//  Copyright (c) 2014 backstopmedia. All rights reserved.
//

import SpriteKit
import GameKit

class GameViewController: UIViewController {    
    @IBOutlet var startGameButton: UIButton!
    
    @IBOutlet var sketchModeSwitch: UISwitch!
    override func viewDidLoad() {
        super.viewDidLoad()
        sketchModeSwitch.on = NSUserDefaults.standardUserDefaults().boolForKey("SketchMode")
        // Setup our SpriteKit view.
        let view = self.view as SKView
//		view.showsFPS = true
//		view.showsNodeCount = true
//      view.ignoresSiblingOrder = true

        
        let startScene = HomeScene()
        view.presentScene(startScene)
        
        // Start the background music.
        SoundManager.playBackgroundMusic()
    }
    

    @IBAction func startGame (sender: AnyObject) {
        let view = self.view as SKView
        
        // Create and present our level scene.
        let levelScene = LevelSelectScene(size: CGSize(width: view.frame.width, height: view.frame.height))
        view.presentScene(levelScene)
        
        for subview in view.subviews {
            if let sView = subview as? UIView {
                sView.hidden = true
            }
        }
    }
    
    @IBAction func sketchModeOption(sender: AnyObject) {
        if let sw = sender as? UISwitch {
            NSUserDefaults.standardUserDefaults().setBool(sw.on, forKey:"SketchMode")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
}

