import UIKit
import RealmSwift

class PlaylistSelectorController : UITableViewController {
    var playlists: Results<PlaylistObject>!
    
    override func viewDidLoad() {
        playlists = RealmWrapper.shared.playlists
    }
    
}
