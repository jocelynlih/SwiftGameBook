//
//  SoundManager.swift
//  PencilAdventure
//
//  Created by Ankur Patel on 8/5/14.
//  Copyright (c) 2014 backstopmedia. All rights reserved.
//

import AVFoundation

private var onceToken : dispatch_once_t = 0
private var SharedPlayer: AVAudioPlayer!
private var BackgroundPlayer: AVAudioPlayer! {
get {
    dispatch_once(&onceToken) {
        let url = NSURL.fileURLWithPath(NSBundle.mainBundle().pathForResource("background", ofType: "mp3"))
        var err: NSError?
        SharedPlayer = AVAudioPlayer(contentsOfURL: url, error: &err)
        if let error = err {
            NSLog("Error %@", error)
        } else {
            SharedPlayer.prepareToPlay()
            SharedPlayer.numberOfLoops = -1
        }
    }
    return SharedPlayer
}
}

class SoundManager {
    
    class func toggleBackgroundMusic() {
        if BackgroundPlayer.playing {
            BackgroundPlayer.pause()
        } else {
            BackgroundPlayer.play()
        }
    }
    
    class func playBackgroundMusic() {
        if !BackgroundPlayer.playing {
            BackgroundPlayer.play()
        }
    }
    
    class func stopBackgroundMusic() {
        if BackgroundPlayer.playing {
            BackgroundPlayer.stop()
        }
    }
    
    class func pauseBackgroundMusic() {
        if BackgroundPlayer.playing {
            BackgroundPlayer.pause()
        }
    }
    
    class func restartBackgroundMusic() {
        BackgroundPlayer.stop()
        BackgroundPlayer.currentTime = 0.0
        BackgroundPlayer.play()
    }
}