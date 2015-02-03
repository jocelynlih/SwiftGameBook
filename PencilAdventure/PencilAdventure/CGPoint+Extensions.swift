
import SpriteKit

extension CGPoint {
  
  func toCGVector() -> CGVector {
    return CGVector(dx: x, dy: y)
  }
  
  func toPoint2D() -> Point2D {
    return Point2D(x: Int(x), y: Int(y))
  }
  
}

func * (left: CGPoint, right: CGFloat) -> CGPoint {
  return CGPoint(x: left.x * right, y: left.y * right)
}

func * (left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x * right.x, y: left.y * right.y)
}

func / (left: CGPoint, right: CGFloat) -> CGPoint {
  return CGPoint(x: left.x / right, y: left.y / right)
}

func / (left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x / right.x, y: left.y / right.y)
}

func + (left: CGPoint, right: CGFloat) -> CGPoint {
  return CGPoint(x: left.x + right, y: left.y + right)
}

func + (left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left: CGPoint, right: CGFloat) -> CGPoint {
  return CGPoint(x: left.x - right, y: left.y - right)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func += (inout left: CGPoint, right: CGPoint) {
  left = left + right
}

func -= (inout left: CGPoint, right: CGPoint) {
  left = left - right
}

func *= (inout left: CGPoint, right: CGPoint) {
  left = left * right
}

func /= (inout left: CGPoint, right: CGPoint) {
  left = left / right
}