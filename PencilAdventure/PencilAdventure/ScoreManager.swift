//
//  ScoreManager.swift
//  PencilAdventure
//
//  Created by Ankur Patel on 8/9/14.
//  Copyright (c) 2014 backstopmedia. All rights reserved.
//

import Foundation

public class ScoreManager {
    class func saveScore(score: Int, forLevel level: Int) {
        var leaderboard = NSUserDefaults.standardUserDefaults().objectForKey("LeaderBoard") as? NSMutableDictionary ?? NSMutableDictionary()
        if let highestScore = leaderboard[level] as? Int {
            leaderboard.setValue(highestScore < score ? score : highestScore, forKey: "Level \(level)")
        } else {
            leaderboard.setValue(score, forKey: "Level \(level)")
        }
        NSUserDefaults.standardUserDefaults().setObject(leaderboard, forKey: "LeaderBoard")
    }
    
    class func getScoreForLevel(level: Int) -> Int? {
        var leaderboard = NSUserDefaults.standardUserDefaults().objectForKey("LeaderBoard") as? NSMutableDictionary ?? NSMutableDictionary()
        return leaderboard[level] as? Int
    }
    
    class func getAllHighScores() -> String? {
        var leaderboard = NSUserDefaults.standardUserDefaults().objectForKey("LeaderBoard") as? NSMutableDictionary ?? NSMutableDictionary()
        var stringBuilder = [String]()
        for (level, score) in leaderboard {
            stringBuilder.append("\(level) - \(score) Points")
        }
        if stringBuilder.count > 0 {
            return Swift.join("\n", stringBuilder)
        } else {
            return .None
        }
    }
}
