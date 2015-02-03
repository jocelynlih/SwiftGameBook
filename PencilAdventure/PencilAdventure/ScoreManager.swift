
import UIKit
import GameKit

public class ScoreManager {
  
  class func saveScore(score: Int, forLevel level: Int) {
    var leaderboard = NSUserDefaults.standardUserDefaults().objectForKey("LeaderBoard") as? NSDictionary ?? NSMutableDictionary()
    var leaderboardMDict: NSMutableDictionary = leaderboard.mutableCopy() as NSMutableDictionary
    
    if let highestScore = leaderboard[level] as? Int {
      leaderboardMDict.setValue(highestScore < score ? score : highestScore, forKey: "Level \(level)")
    } else {
      leaderboardMDict.setValue(score, forKey: "Level \(level)")
    }
    
    NSUserDefaults.standardUserDefaults().setObject(leaderboardMDict, forKey: "LeaderBoard")
    NSUserDefaults.standardUserDefaults().synchronize()
    
    var localPlayer = GKLocalPlayer.localPlayer()
    localPlayer.authenticateHandler = {(viewController : UIViewController!, error : NSError!) -> Void in
      if viewController != .None {
        let appdelegate = UIApplication.sharedApplication().delegate as AppDelegate
        appdelegate.window?.rootViewController?.presentViewController(viewController, animated: true, completion: nil)
      } else {
        if localPlayer.authenticated {
          var scoreToReport = GKScore(leaderboardIdentifier: "Leaderboard\(level)", player: localPlayer)
          scoreToReport.value = Int64(score)
          GKScore.reportScores([scoreToReport], withCompletionHandler: nil)
        } else {
          // User not authenticated
        }
      }
    }
  }
  
  class func getScoreDict() -> NSDictionary {
    return NSUserDefaults.standardUserDefaults().objectForKey("LeaderBoard") as? NSDictionary ?? NSDictionary()
  }
  
  class func getScoreForLevel(level: Int) -> Int? {
    var leaderboard = getScoreDict()
    return leaderboard["Level \(level)"] as? Int
  }
  
  class func getAllHighScores() -> String? {
    var leaderboard = getScoreDict()
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
 
}