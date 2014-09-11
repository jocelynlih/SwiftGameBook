//
//  ScoreManager.swift
//  PencilAdventure
//
//  Created by Ankur Patel on 8/9/14.
//  Copyright (c) 2014 backstopmedia. All rights reserved.
//

import UIKit
import GameKit

var lastScore: Int!

public class ScoreManager {
    
    class func saveScore(score: Int, forLevel level: Int) {
        lastScore = score
        var leaderboard = NSUserDefaults.standardUserDefaults().objectForKey("LeaderBoard") as? NSMutableDictionary ?? NSMutableDictionary()
        if let highestScore = leaderboard[level] as? Int {
            leaderboard.setValue(highestScore < score ? score : highestScore, forKey: "Level \(level)")
        } else {
            leaderboard.setValue(score, forKey: "Level \(level)")
        }
        NSUserDefaults.standardUserDefaults().setObject(leaderboard, forKey: "LeaderBoard")
        
        var localPlayer = GKLocalPlayer.localPlayer()
        localPlayer.authenticateHandler = {(viewController : UIViewController!, error : NSError!) -> Void in
            if viewController != nil {
                let appdelegate = UIApplication.sharedApplication().delegate as AppDelegate
                appdelegate.window?.rootViewController?.presentViewController(viewController, animated: true, completion: nil)
            } else {
                if localPlayer.authenticated {
                    var scoreToReport = GKScore(leaderboardIdentifier: "Leaderboard\(level)", player: localPlayer)
                    scoreToReport.value = Int64(score)
                    GKScore.reportScores([scoreToReport], withCompletionHandler: nil)
                }
            }
        }
    }
    
    class func getScoreForLevel(level: Int) -> Int? {
        var leaderboard = NSUserDefaults.standardUserDefaults().objectForKey("LeaderBoard") as? NSMutableDictionary ?? NSMutableDictionary()
        return leaderboard["Level \(level)"] as? Int
    }
    
    class func getAllHighScores() -> String? {
        var leaderboard = NSUserDefaults.standardUserDefaults().objectForKey("LeaderBoard") as? NSMutableDictionary ?? NSMutableDictionary()
        var stringBuilder = [String]()
        for i in 1...4 {
            let level = "Level \(i)"
            if let score = leaderboard.objectForKey(level) as? Int {
                stringBuilder.append("\(level) - \(score) Points")
            }
        }

        if stringBuilder.count > 0 {
            return Swift.join("\n", stringBuilder)
        } else {
            return .None
        }
    }
    
    class func getLastScore() -> Int {
        return lastScore
    }
}

