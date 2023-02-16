import Foundation
import AVFoundation
import UIKit

// Gerenciador do jogo.
// Tudo relativo a controle que não seja lógica, estará aqui.
// Pontuação, música, pausa, play ...
class GameManager: ObservableObject, GameManagerDelegate {
    @Published var score = 0
    @Published var gamePaused = false

    let lightPurple = UIColor(red: 109/255, green: 83/255, blue: 143/255, alpha: 1)
    let darkPurple = UIColor(red: 48/255, green: 31/255, blue: 64/255, alpha: 1)

    // Cria um tocador de audio conforme a definição da função dentro das chaves
    lazy var musicSoundEffect: AVAudioPlayer? = {
        // Pega o audio, se existir
        guard let soundURL = Bundle.main.url(forResource: "loopsong", withExtension: "mp3") else {
            print("Could not find sound url")
            return nil
        }

        // Pega o tocador de audio, se existir
        guard let player = try? AVAudioPlayer(contentsOf: soundURL) else {
            print("Could not create audio player")
            return nil
        }

        return player
    }()

    // Cria a cena do jogo em si.
    // Olhe o arquivo GameScene.swift, lá que vai ter toda a lógica de física
    lazy var scene: GameScene = {
        let s = GameScene()
        s.scaleMode = .resizeFill
        s.backgroundColor = lightPurple
        s.manager = self
        return s
    }()

    func playSound() {
        musicSoundEffect?.play()
    }

    // Recebe a posição mais alta da bolinha, junto com o espaçamento entre as plataformas
    // A pontuação do jogo é relativa a essa posição
    func newHighestPosition(_ position: CGPoint, interval: CGFloat) {
        let value = Int(abs(position.y) / interval)
        if value > score {
            score = value
        }
    }

    func pauseGame() {
        scene.isPaused = true
        musicSoundEffect?.pause()

        gamePaused = true
    }

    func resumeGame() {
        scene.isPaused = false
        musicSoundEffect?.play()
        
        gamePaused = false
    }
}
