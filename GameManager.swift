import Foundation

class GameManager: ObservableObject, GameManagerDelegate {
    @Published var score = 0

    func newHighestPosition(_ position: CGPoint, interval: CGFloat) {
        let value = Int(abs(position.y) / interval)
        if value > score {
            score = value
        }
    }
}
