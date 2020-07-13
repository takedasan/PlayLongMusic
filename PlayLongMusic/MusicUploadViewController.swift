import UIKit
import Telegraph

class MusicUploadViewController: UIViewController {
    var server: Server!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Run web server
        server = Server()
        try! server.start(port: 9000)
        server.route(.GET, "", handleGet)
        server.route(.POST, "", handlePost)
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
            // Parse a request
            let multipart = Multipart.init(contentType: request.headers.contentType!, body: request.body)
            
            for file in multipart.body.files {
                let savePath = documentsPath.appendingPathComponent(file.fileName)
                try file.data.write(to: savePath, options: Data.WritingOptions.atomic)
            }
        } catch {
            print(error)
            fatalError("File save failed.")
        }
        
        return HTTPResponse(content: String(data: request.body.base64EncodedData(), encoding: .utf8)!)
    }
}
