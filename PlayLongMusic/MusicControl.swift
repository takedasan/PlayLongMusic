import UIKit
import AVFoundation

class MusicControl: UIStackView, AVAudioPlayerDelegate {
    // MARK: Properties
    var musicUrl: URL = URL(fileURLWithPath: "")
    var audioPlayer: AVAudioPlayer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
    }

    func togglePlayButton() {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: musicUrl)
            audioPlayer.delegate = self
            playMusic()
        } catch {
            print(error)
            fatalError("Music File read failed.")
        }
    }
    
    // MARK: Private methods
    private func playMusic() {
        audioPlayer.play()
    }
    
    private func stopMusic() {
        audioPlayer.pause()
    }
}
