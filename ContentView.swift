import SwiftUI
import SpriteKit

struct ContentView: View {
    @StateObject var gameManager = GameManager()

    var body: some View {
        ZStack(alignment: .top) {
            SpriteView(scene: gameManager.scene, debugOptions: [.showsFPS, .showsNodeCount])
                .ignoresSafeArea()

            if gameManager.gamePaused {
                Text("Paused")
                    .font(.system(.largeTitle, design: .rounded))
                    .fontWeight(.black)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.white.opacity(0.3))
            }

            controls
        }
    }

    var controls: some View {
        HStack {
            if gameManager.gamePaused {
                createButton(imageName: "play.fill", action: gameManager.resumeGame)
            } else {
                createButton(imageName: "pause.fill", action: gameManager.pauseGame)
            }

            Spacer()

            Text("Score: \(gameManager.score)")
                .foregroundColor(.white)
                .padding()
                .background(.black)
                .cornerRadius(16)
                .padding()
        }
    }

    @ViewBuilder func createButton(imageName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: imageName)
                .foregroundColor(.white)
                .padding()
                .background(.black)
                .cornerRadius(16)
                .padding()
        }
    }
}
