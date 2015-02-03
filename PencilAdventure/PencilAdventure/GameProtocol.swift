
import SpriteKit

public protocol GameProtocol {
  
  var viewableArea: CGRect! { get }
  
  func gameEnd(didWin: Bool)
  
}

