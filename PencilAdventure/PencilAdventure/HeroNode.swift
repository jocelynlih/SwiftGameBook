
import SpriteKit

// Note that these would normally be class properties, but Swift doesn't currently support class properties.
let SteveMaxFrames = 8
let SteveTextureNameBase = "steve"
var steveWalkingFrames = [SKTexture]()

//currently Steve can run, jump and Die
public enum HeroState {
  case Run, Jump, PowerUp, Death
}

public class HeroNode: SKSpriteNode {
  
  private let SteveAnimationFPS = 15.0
  private var powerUpParticle = SKEmitterNode(fileNamed: "PowerUpParticle")
  private var smokeParticle = SKEmitterNode(fileNamed: "SteveDieParticle")

  public var heroState: HeroState = .Run
  
  convenience init(scene: SKScene, withPhysicsBody: Bool) {
    let atlas = SKTextureAtlas(named: "Steve")
    
    for i in 1 ... SteveMaxFrames {
      let texName = "\(SteveTextureNameBase)\(i)"
      if let texture = atlas.textureNamed(texName) {
        steveWalkingFrames.append(texture)
      }
    }
    
    self.init(texture: steveWalkingFrames[2])
    
    name = "steve"
    xScale = scene.getSceneScaleX()
    yScale = scene.getSceneScaleY()
    zPosition = HeroZPosition
    speed = 1
    powerUpParticle.paused = true
    powerUpParticle.hidden = true
    smokeParticle.paused = true
    smokeParticle.hidden = true
    self.addChild(smokeParticle)
    
    if withPhysicsBody {
      physicsBody = SKPhysicsBody(rectangleOfSize: self.size)
      physicsBody?.dynamic = true
      physicsBody?.allowsRotation = false
      physicsBody?.mass = 0.56 // TODO - Need to decide on a standard for this - maybe we just change this to a constant?
      physicsBody?.categoryBitMask = heroCategory
      physicsBody?.collisionBitMask = levelItemCategory | deathtrapCategory | groundCategory | finishCategory
      physicsBody?.contactTestBitMask = levelItemCategory | powerupCategory | deathtrapCategory | groundCategory | finishCategory
    }
    
    self.addChild(powerUpParticle)
    
    self.runAction(
      SKAction.repeatActionForever(
        SKAction.animateWithTextures(steveWalkingFrames, timePerFrame: 1.0 / SteveAnimationFPS, resize:false, restore:false)
      ), withKey:"steveRun"
    )
  }
  
  public func didGetPowerUp() {
    heroState = .PowerUp
    powerUpParticle.paused = false
    powerUpParticle.hidden = false
    callbackAfter(0.5 as Float) {
      self.powerUpParticle.paused = true
      self.powerUpParticle.hidden = true
      self.heroState = .Run
    }
    self.runAction(SKAction.playSoundFileNamed("collision.mp3", waitForCompletion: false))
  }
  
  public func die() {
    heroState = .Death
    //remove action
    speed = 0
    self.removeActionForKey("steveRun")
    //TODO: add die animation
    
    //remove the physics collsions detect
    physicsBody?.collisionBitMask = 0
    physicsBody?.contactTestBitMask = heroCategory
    //add smoke
    smokeParticle.paused = false
    smokeParticle.hidden = false
    //move up and down
    let moveUp = SKAction.moveBy(CGVector(dx: 0.0, dy: 100.0), duration: 0.1)
    let moveDown = SKAction.moveBy(CGVector(dx: 0.0, dy: -100.0), duration: 0.1)
    let moveUpDown = SKAction.sequence([moveUp, moveDown])
    self.runAction(moveUpDown)
    self.runAction(SKAction.playSoundFileNamed("collision.mp3", waitForCompletion: false))
  }
  
}