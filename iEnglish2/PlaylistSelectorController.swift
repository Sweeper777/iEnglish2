import UIKit
import RealmSwift

class PlaylistSelectorController : UITableViewController {
    var playlists: Results<PlaylistObject>!
    weak var delegate: PlaylistSelectorControllerDelegate?
    
    override func viewDidLoad() {
        playlists = RealmWrapper.shared.playlists
    }
    
    @IBAction func cancelPress() {
        dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlists.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.textLabel?.text = playlists[indexPath.row].name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didSelect(playlistObject: playlists[indexPath.row])
        dismiss(animated: true, completion: nil)
    }
}

protocol PlaylistSelectorControllerDelegate: class {
    func didSelect(playlistObject: PlaylistObject)
}
