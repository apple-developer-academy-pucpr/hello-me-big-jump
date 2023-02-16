import SpriteKit

// Cena do jogo em si.
// Toda a lógica é feita aqui
class GameScene: SKScene, SKPhysicsContactDelegate {

    // Esses dois quadrados servem para calcular as dimensões do dispositivo.
    // Com eles, ajustamos as posições das coisas para aparecer na tela,
    //           independente de estar em retrato ou paisagem
    var minSquare: SKShapeNode!
    var maxSquare: SKShapeNode!

    // Limites da tela. Serve para que a bolinha não saia para fora da tela.
    // A bolinha vai bater e voltar.
    var boundary: SKNode?

    // A bolinha e o chão
    var lightBall: SKSpriteNode!
    var ground: SKSpriteNode!

    // Serve para controlar as plataformas que aparecem no jogo.
    var platforms = [SKSpriteNode]()

    // Referência ao gerenciador do jogo.
    // Serve para pedir para tocar som e informar nova posição da bolinha.
    weak var manager: GameManagerDelegate?

    // Categorias dos objetos que utilizam física.
    // Cada objeto que colide/toca com os demais precisa de uma categoria.
    // A interação de colisão/toque entre os objetos é dada por um número de 32 bits.
    // Se um objeto colide/toca com o outro, a categoria (bit) daquele objeto será usada.
    enum PhysicsCategories {
        static let lightBallCategory: UInt32 = 0x1 << 0 // 2^0
        static let platformCategory: UInt32  = 0x1 << 1 // 2^1
        static let boundaryCategory: UInt32  = 0x1 << 2 // 2^2
    }

    // Posição no eixo z, ou seja, o que aparece na frente do que.
    enum ZPositions {
        static let background: CGFloat = -1
        static let platform: CGFloat = 1
        static let lightBall: CGFloat = 2
    }

    // Essa parte do código é executada logo que a cena começa
    override func didMove(to view: SKView) {
        // Serve para informar contato de objetos.
        // OBS: Contato (toque) é diferente de colisão.
        // Colisão não é informada
        physicsWorld.contactDelegate = self

        // Muda a âncora da cena para o centro.
        anchorPoint = CGPoint(x: 0.5, y: 0.5)

        configureCamera()
        configureBoundaries()
        configureMinAndMaxSquare()

        configureLightBall()
        configureGround()
        configurePlatforms()

        manager?.playSound()
    }

    // Se a cena muda de tamanho, essa função é chamada.
    // Um exemplo é na rotação de dispositivo.
    override func didChangeSize(_ oldSize: CGSize) {
        // Se existir limites de tela e a tela for de tamanho diferente de 1x1:
        //    remove o limite antigo
        //    configura uma nova na posição da antiga
        let one = CGSize(width: 1, height: 1)
        if let boundary = self.boundary, size != one {
            boundary.removeFromParent()
            configureBoundaries(at: boundary.position)

            // Se a bolinha não estiver no quadrado mínimo:
            //    reconfigura a bolinha colocando no centro (posição da câmera)
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

    // Cria o limite da tela. Por padrão, a posição é (0, 0)
    func configureBoundaries(at position: CGPoint = .zero) {
        // Cria um limite de tela que colide com a bolinha
        let newBoundary = SKNode()
        newBoundary.physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        newBoundary.physicsBody?.categoryBitMask = PhysicsCategories.boundaryCategory
        newBoundary.physicsBody?.collisionBitMask = PhysicsCategories.lightBallCategory
        newBoundary.position = position

        // Adiciona o limite criado a cena e muda a referência da antiga pra nova
        addChild(newBoundary)
        boundary = newBoundary
    }

    // Calcula as dimensões mínimas e máximas da tela.
    // Isso serve pra posicionar os objetos em lugares que vão aparecer,
    //      mesmo mudando de paisagem para retrato e vice-versa.
    func configureMinAndMaxSquare() {
        let minSide = min(size.height, size.width)
        let maxSide = max(size.height, size.width)

        minSquare = SKShapeNode(rectOf: CGSize(width: minSide, height: minSide))
        minSquare.strokeColor = .clear // Mude o .clear para .blue se quiser ver o quadrado mínimo

        maxSquare = SKShapeNode(rectOf: CGSize(width: maxSide, height: maxSide))
        maxSquare.strokeColor = .clear // Mude o .clear para .red se quiser ver o quadrado máximo

        // Adiciona os quadrados na cena
        addChild(minSquare)
        addChild(maxSquare)
    }

    func configureLightBall() {
        // Cria bolinha, dá nome, posiciona no centro e diz profundidade
        lightBall = SKSpriteNode(imageNamed: "lightball")
        lightBall.name = "lightball"
        lightBall.position = CGPoint(x: frame.midX - lightBall.frame.midX, y: frame.midY - lightBall.frame.midX)
        lightBall.zPosition = ZPositions.lightBall

        // Configura a física da bolinha
        lightBall.physicsBody = SKPhysicsBody(circleOfRadius: lightBall.size.width / 2)

        // Sofre força da gravidade? Se move por colisões?
        lightBall.physicsBody?.affectedByGravity = true
        lightBall.physicsBody?.isDynamic = true

        // O quanto quica de 0.0 a 1.0?
        lightBall.physicsBody?.restitution = 0.75

        // Qual a categoria física?
        lightBall.physicsBody?.categoryBitMask = PhysicsCategories.lightBallCategory

        // Com qual ou quais objetos colide? Com qual ou quais faz contato? (contato é notificado)
        lightBall.physicsBody?.collisionBitMask = PhysicsCategories.boundaryCategory
        lightBall.physicsBody?.contactTestBitMask = PhysicsCategories.platformCategory

        addChild(lightBall)
    }

    func configureGround() {
        // Cria chão, posiciona na base do menor quadrado e diz profundidade
        ground = SKSpriteNode(imageNamed: "neverendingbar")
        ground.position = CGPoint(x: maxSquare.frame.midX, y: minSquare.frame.minY + ground.frame.height / 2)
        ground.zPosition = ZPositions.platform

        // Configura física do chão
        ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)

        // Sofre força da gravidade? Se move por colisões?
        ground.physicsBody?.affectedByGravity = false
        ground.physicsBody?.isDynamic = false

        // Qual a categoria física?
        ground.physicsBody?.categoryBitMask = PhysicsCategories.platformCategory

        addChild(ground)
    }

    // Cria as plataformas do começo do jogo, a partir do chão até o limite da tela.
    // De 100 em 100 pixels pra cima, uma plataforma é criada.
    // A posição horizontal é aleatória.
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
        // Cria plataforma na posição recebida e posicionamento especificado.
        let platform = SKSpriteNode(imageNamed: "simplebar")
        platform.position = position
        platform.zPosition = ZPositions.platform

        // Configura física da plataforma (parecido com a configuração do chão)
        platform.physicsBody = SKPhysicsBody(rectangleOf: platform.size)
        platform.physicsBody?.affectedByGravity = false
        platform.physicsBody?.isDynamic = false
        platform.physicsBody?.categoryBitMask = PhysicsCategories.platformCategory

        // Adiciona a platafoma na cena
        addChild(platform)

        // Guarda a referência da plataforma para controle
        platforms.append(platform)
    }

    // Função chamada antes de cada frame.
    override func update(_ currentTime: TimeInterval) {
        guard let cameraPosition = self.camera?.position else { return }

        // Se a bolinha estiver pra cima da posição central da câmera
        if lightBall.position.y > cameraPosition.y {
            let difference = lightBall.position.y - cameraPosition.y

            // Sobe os objetos para a mesma altura da bolinha
            camera?.position.y += difference
            boundary?.position.y += difference
            minSquare.position.y += difference
            maxSquare.position.y += difference
            ground.position.y += difference

            // Atualiza as plataformas, adiciona se precisar e remove as que der
            updatePlatforms()

            // Informa o gerenciador do jogo a posição da bolinha
            manager?.newHighestPosition(lightBall.position, interval: 100)
        }
    }

    func updatePlatforms() {
        // Se a última plataforma estiver aparecendo na tela, crie uma nova
        // Ela vai ser criada numa posição que fica pra fora da tela
        let upperBoundary = maxSquare.frame.maxY
        if let lastPlatform = platforms.last, lastPlatform.position.y < upperBoundary {
            let newX = CGFloat.random(in: frame.minX...frame.maxX)
            let newY = lastPlatform.position.y + 100
            addPlatform(at: CGPoint(x: newX, y: newY))
        }

        // Se a primeira plataforma estive pra baixo do chão, remove ele da tela
        let lowerBoundary = ground.position.y
        if let firstPlatform = platforms.first, firstPlatform.position.y < lowerBoundary {
            platforms.remove(at: 0)
            firstPlatform.removeFromParent()
        }
    }

    // Quando tocamos na tela, essa função é chamada
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        handleTouch(touch)
    }

    // Quando movemos o dedo na tela, essa função é chamada
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        handleTouch(touch)
    }

    // Ao clicar, movemos a bolinha em direção ao dedo horizontalmente.
    func handleTouch(_ touch: UITouch) {
        let location = touch.location(in: self)

        if location.x > lightBall.position.x {
            lightBall.physicsBody?.applyForce(CGVector(dx: 500, dy: 0))
        } else {
            lightBall.physicsBody?.applyForce(CGVector(dx: -500, dy: 0))
        }
    }

    // Quando dois objetos fazem contato, essa função é chamada.
    // Nesse jogo, somente a bolinha tem definida a propriedade .contactTestBitMask
    //       lightBall.physicsBody?.contactTestBitMask = PhysicsCategories.platformCategory
    //
    // Assim, quando a bolinha entra em contato com um objeto "platformCategory",
    //        essa função é chamada.
    func didBegin(_ contact: SKPhysicsContact) {
        // Se a direção do contato no eixo y é para cima, faça a bolinha pular
        if contact.contactNormal.dy > 0 {
            lightBallJump()
        }
    }

    func lightBallJump() {
        // Aumenta a velocidade no eixo y da bolinha, fazendo ela subir
        lightBall.physicsBody?.velocity.dy = 900
    }
}
