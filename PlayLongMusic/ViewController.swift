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
        server.route(.GET, "", handleGet)
        server.route(.POST, "", handlePost)
    }
    
    // MARK: Actions
    @IBAction func pushPlayButton(_ sender: UIButton) {
        self.togglePlayButton()
    }
    
    // MARK: Private methods
    private func handleGet(request: HTTPRequest) -> HTTPResponse {
        let htmlFile = Bundle.main.path(forResource: "uploadform", ofType: "html")
        
        do {
            let htmlString = try String(contentsOfFile: htmlFile!, encoding: String.Encoding.utf8)
            return HTTPResponse(content: htmlString)
        } catch {
            print(error)
            fatalError("Uploader HTML file is not found.")
        }
    }

    private func handlePost(request: HTTPRequest) -> HTTPResponse {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        do {
            let multipart = Multipart.init(contentType: request.headers.contentType!, body: request.body)
            let savePath = documentsPath.appendingPathComponent(multipart.body.file[0].fileName)
            
            try multipart.body.file[0].data.write(to: savePath, options: Data.WritingOptions.atomic)
        } catch {
            print(error)
            fatalError("File save failed.")
        }
        
        return HTTPResponse(content: String(data: request.body.base64EncodedData(), encoding: .utf8)!)
    }
    
    private func togglePlayButton() {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let audioUrl = URL(fileURLWithPath: documentsPath).appendingPathComponent("hoge.mp3")
        
        print(audioUrl)
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioUrl)
            audioPlayer.delegate = self
        } catch {
            print(error)
            fatalError("Music File read failed.")
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

