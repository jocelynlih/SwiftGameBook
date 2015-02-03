
import SpriteKit

class ProgressLoaderNode: SKCropNode {
  
  private let markerSprite: HeroNode!
  private let progressBarSprite: SKSpriteNode!
  private let ProgressMarkerScalar: CGFloat = 0.3
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  init (scene: SKScene) {
    super.init()
    
    xScale = scene.getSceneScaleX()
    yScale = scene.getSceneScaleY()
    
    // Add our progress background
    let spriteAtlas = SKTextureAtlas(named: "Sprites")
    progressBarSprite = SKSpriteNode(texture: spriteAtlas.textureNamed("progress"))
    self.addChild(progressBarSprite)
    
    // Add our moving marker
    markerSprite = HeroNode(scene: scene, withPhysicsBody: false)
    
    // Let's scale our marker
    markerSprite.setScale(ProgressMarkerScalar)
    
    self.addChild(markerSprite)
  }
  
  func setProgress (progress: CGFloat) {
    if let marker = markerSprite {
      // We move the total distance of the progressBarSprite minus the width of our marker (so it moves from inside
      // edge to inside edge within the progress bar)
      let markerWidth = markerSprite.frame.size.width
      let progressWidth = progressBarSprite.frame.size.width
      
      // The progress bar's anchor is in the center, so the distance to either edge (left or right edge) will be half
      // of the preogress bar's width.
      //
      // Since we want our marker sprite to rest just inside that edge, we just need to subtract half of the width of
      // the marker sprite.
      let distanceToProgressEdge = progressWidth / 2 - markerWidth
      
      // Left edge is the negative distance to edge
      let leftEdge = -distanceToProgressEdge
      
      // Right edge is positive distance to edge
      let rightEdge = distanceToProgressEdge
      
      // Total distance to move
      let totalDistanceToMove = rightEdge - leftEdge
      
      // Start at the left edge of the progress
      marker.position.x = leftEdge + totalDistanceToMove * progress
    }
  }
  
}