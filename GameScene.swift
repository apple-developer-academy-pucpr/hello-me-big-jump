import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var minSquare: SKShapeNode!
    var maxSquare: SKShapeNode!

    var boundary: SKNode?

    var lightBall: SKSpriteNode!
    var ground: SKSpriteNode!

    let lightBallCategory: UInt32 = 1 // 2^0
    let platformCategory: UInt32  = 2 // 2^1
    let boundaryCategory: UInt32  = 4 // 2^2

    var platforms = [SKSpriteNode]()

    weak var manager: GameManagerDelegate?

    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self

        backgroundColor = UIColor(red: 109/255, green: 83/255, blue: 143/255, alpha: 1)
        anchorPoint = CGPoint(x: 0.5, y: 0.5)

        configureCamera()
        configureBoundaries()
        configureMinAndMaxSquare()

        configureLightBall()
        configureGround()
        configurePlatforms()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        let one = CGSize(width: 1, height: 1)
        if let boundary = self.boundary, size != one {
            boundary.removeFromParent()
            configureBoundaries(at: boundary.position)

            if !minSquare.frame.contains(lightBall.position) {
                lightBall.removeFromParent()
                configureLightBall()

                if let cameraPosition = camera?.position {
                    lightBall.position = cameraPosition
                }
            }
        }
    }

    func configureCamera() {
        let camera = SKCameraNode()
        camera.position = CGPoint(x: frame.midX, y: frame.midY)
        self.camera = camera

        addChild(camera)
    }

    func configureBoundaries(at position: CGPoint = .zero) {
        let newBoundary = SKNode()
        newBoundary.physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        newBoundary.physicsBody?.categoryBitMask = boundaryCategory
        newBoundary.physicsBody?.collisionBitMask = lightBallCategory
        newBoundary.position = position

        addChild(newBoundary)
        boundary = newBoundary
    }

    func configureMinAndMaxSquare() {
        let minSide = min(size.height, size.width)
        let maxSide = max(size.height, size.width)

        minSquare = SKShapeNode(rectOf: CGSize(width: minSide, height: minSide))
        minSquare.strokeColor = .blue

        maxSquare = SKShapeNode(rectOf: CGSize(width: maxSide, height: maxSide))
        maxSquare.strokeColor = .red

        addChild(minSquare)
        addChild(maxSquare)
    }

    func configureLightBall() {
        lightBall = SKSpriteNode(imageNamed: "lightball")
        lightBall.name = "lightball"
        lightBall.position = CGPoint(x: frame.midX - lightBall.frame.midX, y: frame.midY - lightBall.frame.midX)
        lightBall.zPosition = 2

        lightBall.physicsBody = SKPhysicsBody(circleOfRadius: lightBall.size.width / 2)
        lightBall.physicsBody?.affectedByGravity = true
        lightBall.physicsBody?.isDynamic = true
        lightBall.physicsBody?.restitution = 0.75
        lightBall.physicsBody?.categoryBitMask = lightBallCategory
        lightBall.physicsBody?.collisionBitMask = boundaryCategory
        lightBall.physicsBody?.contactTestBitMask = platformCategory

        addChild(lightBall)
    }

    func configureGround() {
        ground = SKSpriteNode(imageNamed: "neverendingbar")
        ground.position = CGPoint(x: maxSquare.frame.midX, y: minSquare.frame.minY + ground.frame.height / 2)
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

        while posY < maxSquare.frame.maxY {
            let posX = CGFloat.random(in: frame.minX...frame.maxX)
            addPlatform(at: CGPoint(x: posX, y: posY))
            posY += interval
        }
    }

    func addPlatform(at position: CGPoint) {
        let platform = SKSpriteNode(imageNamed: "simplebar")
        platform.position = position
        platform.zPosition = 1

        platform.physicsBody = SKPhysicsBody(rectangleOf: platform.size)
        platform.physicsBody?.affectedByGravity = false
        platform.physicsBody?.isDynamic = false
        platform.physicsBody?.categoryBitMask = platformCategory

        addChild(platform)
        platforms.append(platform)
    }

    override func update(_ currentTime: TimeInterval) {
        guard let cameraPosition = self.camera?.position else { return }

        if lightBall.position.y > cameraPosition.y {
            let difference = lightBall.position.y - cameraPosition.y

            camera?.position.y += difference
            boundary?.position.y += difference
            minSquare.position.y += difference
            maxSquare.position.y += difference
            ground.position.y += difference

            updatePlatforms()

            manager?.newHighestPosition(lightBall.position, interval: 100)
        }
    }

    func updatePlatforms() {
        let upperBoundary = maxSquare.frame.maxY
        if let lastPlatform = platforms.last, lastPlatform.position.y < upperBoundary {
            let newX = CGFloat.random(in: frame.minX...frame.maxX)
            let newY = lastPlatform.position.y + 100
            addPlatform(at: CGPoint(x: newX, y: newY))
        }

        let lowerBoundary = ground.position.y
        if let firstPlatform = platforms.first, firstPlatform.position.y < lowerBoundary {
            platforms.remove(at: 0)
            firstPlatform.removeFromParent()
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

        if location.x > lightBall.position.x {
            lightBall.physicsBody?.applyForce(CGVector(dx: 500, dy: 0))
        } else {
            lightBall.physicsBody?.applyForce(CGVector(dx: -500, dy: 0))
        }
    }

    func didBegin(_ contact: SKPhysicsContact) {
        if contact.contactNormal.dy > 0 {
            lightBallJump()
        }
    }

    func lightBallJump() {
        lightBall.physicsBody?.velocity.dy = 900
    }
}
