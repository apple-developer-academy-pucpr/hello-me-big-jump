import Foundation

class GameManager: ObservableObject, GameManagerDelegate {
    @Published var score = 0
    @Published var gamePaused = false

    lazy var scene: GameScene = {
        let s = GameScene()
        s.scaleMode = .resizeFill
        s.manager = self
        return s
    }()

    func newHighestPosition(_ position: CGPoint, interval: CGFloat) {
        let value = Int(abs(position.y) / interval)
        if value > score {
            score = value
        }
    }

    func pauseGame() {
        scene.isPaused = true
        gamePaused = true
    }

    func resumeGame() {
        scene.isPaused = false
        gamePaused = false
    }
}
