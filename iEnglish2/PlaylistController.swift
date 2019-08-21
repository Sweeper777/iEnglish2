import UIKit
import RealmSwift
import RxSwift
import RxCocoa
import RxDataSources
import EmptyDataSet_Swift
import SCLAlertView
import SwiftyUtils

class PlaylistController: UITableViewController {
    let disposeBag = DisposeBag()
    
    var playlistObjects: Results<PlaylistObject>!
    var playlists: BehaviorRelay<[Playlist]> = BehaviorRelay(value: [])
    
}
