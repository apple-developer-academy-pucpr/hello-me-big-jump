import SwiftUI
import SpriteKit

struct ContentView: View {
    @StateObject var gameManager = GameManager()
    
    var scene: SKScene {
        let scene = GameScene()
        scene.manager = gameManager
        scene.scaleMode = .resizeFill
        return scene
    }
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            SpriteView(scene: scene, debugOptions: [.showsFPS, .showsNodeCount])
                .ignoresSafeArea()

            Text("Score: \(gameManager.score)")
                .foregroundColor(.white)
                .padding()
                .background(.black)
                .cornerRadius(16)
                .padding()
        }
    }
}
