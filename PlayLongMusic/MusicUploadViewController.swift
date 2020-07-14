import UIKit
import Telegraph

class MusicUploadViewController: UIViewController {
    var server = Server()
    @IBOutlet weak var logTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup server methods
        server.route(.GET, "", handleGet)
        server.route(.POST, "", handlePost)
    }
    
    // MARK: UI Action
    @IBAction func handleServerSwitch(_ sender: UISwitch) {
        if(sender.isOn) {
            try! server.start(port: 9000)
        } else {
            server.stop()
        }
    }

    // MARK: Server method
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
            // Parse a request
            let multipart = Multipart.init(contentType: request.headers.contentType!, body: request.body)
            
            for file in multipart.body.files {
                let savePath = documentsPath.appendingPathComponent(file.fileName)
                try file.data.write(to: savePath, options: Data.WritingOptions.atomic)
                
                // print to view
                DispatchQueue.main.async {
                    self.logTextView.text = file.fileName
                }
            }
        } catch {
            print(error)
            fatalError("File save failed.")
        }
        
        return HTTPResponse(content: String(data: request.body.base64EncodedData(), encoding: .utf8)!)
    }
}
