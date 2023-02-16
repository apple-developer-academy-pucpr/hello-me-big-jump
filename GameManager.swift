import Foundation
import UIKit

class GameManager: ObservableObject, GameManagerDelegate {
    @Published var score = 0
    @Published var gamePaused = false

    let lightPurple = UIColor(red: 109/255, green: 83/255, blue: 143/255, alpha: 1)
    let darkPurple = UIColor(red: 48/255, green: 31/255, blue: 64/255, alpha: 1)

    lazy var scene: GameScene = {
        let s = GameScene()
        s.scaleMode = .resizeFill
        s.backgroundColor = lightPurple
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
