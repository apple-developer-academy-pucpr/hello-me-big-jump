import SwiftUI
import SpriteKit

struct ContentView: View {
    // Gerenciador do jogo.
    // Pontuação, controle de pause e resume, música e demais coisas estão lá.
    @StateObject var gameManager = GameManager()

    var body: some View {
        // Mostra itens em sobreposição
        ZStack(alignment: .top) {

            // Carrega a cena do jogo
            SpriteView(scene: gameManager.scene, debugOptions: [.showsFPS, .showsNodeCount])
                .ignoresSafeArea()

            // Se o jogo estiver pausado, mostra o texto "Paused" com os estilos definidos
            if gameManager.gamePaused {
                Text("Paused")
                    .font(.system(.largeTitle, design: .rounded))
                    .fontWeight(.black)
                    .foregroundColor(Color(uiColor: gameManager.darkPurple))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.white.opacity(0.3))
            }

            // Controles do jogo e pontuação
            controls
        }
    }

    var controls: some View {
        // Mostra itens na horizontal
        HStack {

            // Se o jogo estiver pausado: cria botão de play
            // Caso contrário: cria botão de pause
            if gameManager.gamePaused {
                createButton(imageName: "play.fill", action: gameManager.resumeGame)
            } else {
                createButton(imageName: "pause.fill", action: gameManager.pauseGame)
            }

            Spacer()

            // Texto com pontuação no estilo definido
            Text("Score: \(gameManager.score)")
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .padding()
                .cornerRadius(16)
        }
        .padding()
    }

    @ViewBuilder func createButton(imageName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: imageName)
                .foregroundColor(Color(uiColor: gameManager.darkPurple))
                .padding()
                .background(.white)
                .cornerRadius(16)
        }
    }
}
