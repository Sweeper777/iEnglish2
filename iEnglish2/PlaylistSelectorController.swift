import UIKit
import RealmSwift

class PlaylistSelectorController : UITableViewController {
    var playlists: Results<PlaylistObject>!
    
    override func viewDidLoad() {
        playlists = RealmWrapper.shared.playlists
    }
    
    @IBAction func cancelPress() {
        dismiss(animated: true, completion: nil)
    }
    
}
