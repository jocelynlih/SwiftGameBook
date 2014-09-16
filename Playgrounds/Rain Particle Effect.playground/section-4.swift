let sceneView = SKView(frame: CGRect(x: 0, y: 0, width: 850, height: 638))
let scene = SKScene(fileNamed: "GameScene")
scene.scaleMode = .AspectFill
sceneView.presentScene(scene)

