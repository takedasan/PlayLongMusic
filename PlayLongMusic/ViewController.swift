import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioPlayerDelegate {
    
    // MARK: Properties
    var audioPlayer: AVAudioPlayer!
    
    // MARK: UI Properties
    @IBOutlet weak var playButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    // MARK: Actions
    @IBAction func pushPlayButton(_ sender: UIButton) {
        self.updatePlayButton()
    }
    
    // MARK: Private methods
    private func updatePlayButton() {
        let audioPath = Bundle.main.path(forResource: "sample", ofType:"mp3")!
        let audioUrl = URL(fileURLWithPath: audioPath)
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioUrl)
            audioPlayer.delegate = self
            audioPlayer.play()
        } catch {
        }
    }
}

