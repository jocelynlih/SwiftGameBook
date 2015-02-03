
import SpriteKit

extension CGFloat {
  
  static func randomScalar() -> CGFloat {
    // Get a random value - we use a large range for more precision in the scalar returned
    let rand = Int(arc4random_uniform(UInt32(Int32.max)))
    
    // Divide by the full range of possible random values to give 0...1
    return CGFloat(rand) / CGFloat(Int(Int32.max))
  }
  
  static func randomScalarSigned() -> CGFloat {
    // Get a random value - we use a large range for more precision in the scalar returned
    let rand = Int(arc4random_uniform(UInt32(Int32.max)))
    
    // Divide by half the range of possible random values to give 0...2, then subtract 1 to get -1...+1
    return CGFloat(rand) / CGFloat(Int(Int32.max / 2)) - 1
  }
  
  static func randomValue(range: CGFloat) -> CGFloat {
    return randomScalar() * range
  }
  
  static func randomValueSigned(range: CGFloat) -> CGFloat {
    return randomScalarSigned() * range
  }
  
}