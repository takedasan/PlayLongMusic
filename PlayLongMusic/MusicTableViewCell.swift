import UIKit
import AVFoundation

class MusicTableViewCell: UITableViewCell, AVAudioPlayerDelegate {
    // MARK: Properties
    var musicUrl: URL = URL(fileURLWithPath: "")
    var audioPlayer: AVAudioPlayer!
    
    // MARK: UI Properties
    @IBOutlet weak var playStopButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: Acitions
    @IBAction func onPlessPlayStopButton(_ sender: UIButton) {
        togglePlayButton()
    }
    
    // MARK: Private methods
    private func togglePlayButton() {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: musicUrl)
            audioPlayer.delegate = self
        } catch {
            print(error)
            fatalError("Music File read failed.")
        }
        
        if(playStopButton.titleLabel?.text == "play") {
            playStopButton.setTitle("stop", for: .normal)
            self.playMusic()
        } else {
            playStopButton.setTitle("play", for: .normal)
            self.stopMusic()
        }
    }
    
    private func playMusic() {
        audioPlayer.play()
    }
    
    private func stopMusic() {
        audioPlayer.pause()
    }
}
