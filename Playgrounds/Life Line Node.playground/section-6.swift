public class LifeLineNode: SKCropNode {
    
    private var lifeLine: CGFloat = 1.0
    private var gameScene: SKScene?
    
    convenience init(forScene scene: SKScene) {
        self.init()
        
        gameScene = scene
        
        // Start reducing led from the pencil
        callbackAfter(0.10, subtractPoints)
        
        let healthSprite = SKSpriteNode(imageNamed: "health")
        healthSprite.xScale = scene.getSceneScaleX()
        healthSprite.yScale = scene.getSceneScaleY()
        addChild(healthSprite)

        position.x = scene.frame.width - 100
        position.y = scene.frame.height - 100
                
        // Create the maskNode
        maskNode = SKSpriteNode(color: SKColor.whiteColor(), size: healthSprite.size)
    }
    
    private func subtractPoints() {
        lifeLine -= 0.01
        self.maskNode.yScale = lifeLine
        if lifeLine > 0 {
            callbackAfter(0.1, subtractPoints)
        } else {
            println("Game Over")
        }
    }
    
    public func addLifeLine(life: CGFloat) {
        // Give more led till Mr Pencil reaches the end
        if lifeLine < 1 {
            lifeLine += life
        }
        maskNode.yScale = lifeLine
    }
    
}

