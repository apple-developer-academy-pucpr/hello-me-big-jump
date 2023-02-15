import SpriteKit

class GameScene: SKScene {
    var lightBall: SKSpriteNode!
    var ground: SKSpriteNode!

    override func didMove(to view: SKView) {
        backgroundColor = UIColor(red: 109/255, green: 83/255, blue: 143/255, alpha: 1)
        anchorPoint = CGPoint(x: 0.5, y: 0.5)

        configureLightBall()
        configureGround()
        configurePlatforms()
    }

    func configureLightBall() {
        lightBall = SKSpriteNode(imageNamed: "lightball")
        lightBall.name = "lightball"
        lightBall.position = CGPoint(x: frame.midX - lightBall.frame.midX, y: frame.midY - lightBall.frame.midX)
        lightBall.zPosition = 2

        addChild(lightBall)
    }

    func configureGround() {
        ground = SKSpriteNode(imageNamed: "neverendingbar")
        ground.position = CGPoint(x: frame.midX, y: frame.minY + ground.frame.height / 2)
        ground.zPosition = 1

        addChild(ground)
    }

    func configurePlatforms() {
        let interval = CGFloat(100)

        var posY = ground.position.y + interval

        while posY < frame.maxY {
            let posX = CGFloat.random(in: frame.minX...frame.maxX)

            let platform = SKSpriteNode(imageNamed: "simplebar")
            platform.position = CGPoint(x: posX, y: posY)
            platform.zPosition = 1

            addChild(platform)

            posY += interval
        }
    }
}
