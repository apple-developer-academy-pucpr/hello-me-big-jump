import Foundation
import CoreGraphics

protocol GameManagerDelegate: AnyObject {
    func newHighestPosition(_ position: CGPoint, interval: CGFloat)
}
