
import SpriteKit
import GameKit

class GameViewController: UIViewController {
  
  @IBOutlet var startGameButton: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Setup our SpriteKit view.
    let view = self.view as SKView
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
  
}