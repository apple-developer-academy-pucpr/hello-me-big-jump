import SpriteKit

class GameScene: SKScene {
    var boundary: SKNode!

    var lightBall: SKSpriteNode!
    var ground: SKSpriteNode!

    let lightBallCategory: UInt32 = 1 // 2^0
    let platformCategory: UInt32  = 2 // 2^1
    let boundaryCategory: UInt32  = 4 // 2^2

    override func didMove(to view: SKView) {
        backgroundColor = UIColor(red: 109/255, green: 83/255, blue: 143/255, alpha: 1)
        anchorPoint = CGPoint(x: 0.5, y: 0.5)

        configureLightBall()
        configureGround()
        configurePlatforms()

        configureBoundaries()
    }

    func configureBoundaries() {
        boundary = SKNode()
        boundary.physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        boundary.physicsBody?.categoryBitMask = boundaryCategory
        boundary.physicsBody?.collisionBitMask = lightBallCategory
        boundary.position = .zero

        addChild(boundary)

        lightBall.physicsBody?.applyForce(CGVector(dx: 200, dy: 200))
    }

    func configureLightBall() {
        lightBall = SKSpriteNode(imageNamed: "lightball")
        lightBall.name = "lightball"
        lightBall.position = CGPoint(x: frame.midX - lightBall.frame.midX, y: frame.midY - lightBall.frame.midX)
        lightBall.zPosition = 2

        lightBall.physicsBody = SKPhysicsBody(circleOfRadius: lightBall.size.width / 2)
        lightBall.physicsBody?.affectedByGravity = true
        lightBall.physicsBody?.isDynamic = true
        lightBall.physicsBody?.restitution = 1
        lightBall.physicsBody?.categoryBitMask = lightBallCategory
        lightBall.physicsBody?.collisionBitMask = platformCategory | boundaryCategory

        addChild(lightBall)
    }

    func configureGround() {
        ground = SKSpriteNode(imageNamed: "neverendingbar")
        ground.position = CGPoint(x: frame.midX, y: frame.minY + ground.frame.height / 2)
        ground.zPosition = 1

        ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
        ground.physicsBody?.affectedByGravity = false
        ground.physicsBody?.isDynamic = false
        ground.physicsBody?.categoryBitMask = platformCategory

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

            platform.physicsBody = SKPhysicsBody(rectangleOf: platform.size)
            platform.physicsBody?.affectedByGravity = false
            platform.physicsBody?.isDynamic = false
            platform.physicsBody?.categoryBitMask = platformCategory

            addChild(platform)

            posY += interval
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        handleTouch(touch)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        handleTouch(touch)
    }

    func handleTouch(_ touch: UITouch) {
        let location = touch.location(in: self)

        if location.x > 0 {
            lightBall.physicsBody?.applyForce(CGVector(dx: 500, dy: 0))
        } else {
            lightBall.physicsBody?.applyForce(CGVector(dx: -500, dy: 0))
        }
    }
}
