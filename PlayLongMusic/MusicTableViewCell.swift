import UIKit

class MusicTableViewCell: UITableViewCell {
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
    }
}
