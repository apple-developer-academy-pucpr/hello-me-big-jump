import Foundation
import CoreGraphics

// Abstração do gerenciador de jogo
protocol GameManagerDelegate: AnyObject {
    func newHighestPosition(_ position: CGPoint, interval: CGFloat)
    func playSound()
}
