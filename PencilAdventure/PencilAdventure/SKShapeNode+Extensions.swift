
import SpriteKit

extension SKShapeNode {
  
  func log() {
    NSLog(" Name     : %@", name!)
    NSLog(" Position : %@, %@", position.x, position.y)
    NSLog(" Frame    : %@, %@ - %@ x %@", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height)
    NSLog(" Scale    : %@, %@", xScale, yScale)
    NSLog(" zRotation: %@", zRotation)
    NSLog(" zPosition: %@", zPosition)
  }
  
}