import UIKit
import AVFoundation
import Telegraph

class ViewController: UIViewController, AVAudioPlayerDelegate {
    
    // MARK: Properties
    var audioPlayer: AVAudioPlayer!
    var server: Server!
    
    // MARK: UI Properties
    @IBOutlet weak var playButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        server = Server()
        try! server.start(port: 9000)
        server.route(.GET, "", handle)
        server.route(.POST, "", handlePost)
    }

    func handlePost(request: HTTPRequest) -> HTTPResponse {
        return HTTPResponse(content: request.body.base64EncodedString())
    }
    
    func handle(request: HTTPRequest) -> HTTPResponse {
        return HTTPResponse(content: #"<b>desuto</b> <form action="/" method="post"><input type="file" accept="image/png, image/jpeg"></input><input type="submit" value="Upload Image" name="submit"></form>"#)
    }

    // MARK: Actions
    @IBAction func pushPlayButton(_ sender: UIButton) {
        self.togglePlayButton()
    }
    
    // MARK: Private methods
    private func togglePlayButton() {
        let audioPath = Bundle.main.path(forResource: "sample", ofType:"mp3")!
        let audioUrl = URL(fileURLWithPath: audioPath)
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioUrl)
            audioPlayer.delegate = self
            
        } catch {
            // TODO 握り潰し
        }
        
        if(playButton.titleLabel?.text == "play") {
            playButton.setTitle("stop", for: .normal)
            self.playMusic()
        } else {
            playButton.setTitle("play", for: .normal)
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

