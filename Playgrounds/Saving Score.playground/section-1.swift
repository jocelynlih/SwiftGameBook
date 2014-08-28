import UIKit

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
        return leaderboard["Level \(level)"] as? Int
    }
    
    class func getAllHighScores() -> String? {
        var leaderboard = NSUserDefaults.standardUserDefaults().objectForKey("LeaderBoard") as? NSMutableDictionary ?? NSMutableDictionary()
        var stringBuilder = [String]()
        for (level, score) in leaderboard as NSDictionary {
            stringBuilder.append("\(level) - \(score) Points")
        }
        if stringBuilder.count > 0 {
            return Swift.join("\n", stringBuilder)
        } else {
            return .None
        }
    }
}

ScoreManager.saveScore(10, forLevel: 1)

ScoreManager.getAllHighScores()!

ScoreManager.getScoreForLevel(1)!

ScoreManager.saveScore(20, forLevel: 2)

ScoreManager.getAllHighScores()!