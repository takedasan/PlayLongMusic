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
        let htmlFile = Bundle.main.path(forResource: "uploadform", ofType: "html")
        
        do {
            let data = try String(contentsOfFile: htmlFile!, encoding: String.Encoding.utf8)
            return HTTPResponse(content: data)
        }catch _ as NSError {
            fatalError("Uploader HTML file is not found.")
        }
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

