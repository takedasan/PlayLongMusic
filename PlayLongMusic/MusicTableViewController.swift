import UIKit
import Telegraph

class MusicTableViewController: UITableViewController {
    
    // MARK: Properties
    var musics = [Music]()
    var server: Server!

    override func viewDidLoad() {
        super.viewDidLoad()

        server = Server()
        try! server.start(port: 9000)
        server.route(.GET, "", handleGet)
        server.route(.POST, "", handlePost)
        
        loadMusics()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return musics.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "MusicTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? MusicTableViewCell else {
            fatalError("The dequeued cell is not instance of MusicTableViewCell")
        }
        
        let music = musics[indexPath.row]
        cell.musicUrl = music.url
        
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
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
    
    private func loadMusics() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        do {
            let directoryContents = try FileManager.default
                .contentsOfDirectory(at: documentsPath, includingPropertiesForKeys: nil)
                .filter{ $0.pathExtension == "mp3" }
            
            for content in directoryContents {
                guard let music = Music(url: content) else {
                    fatalError("Unable to instantiate music")
                }
                musics.append(music)
            }
        } catch {
            print(error)
            fatalError("Music File read failed")
        }
    }
}
