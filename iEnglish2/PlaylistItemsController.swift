import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class PlaylistItemsController: UITableViewController {
    let disposeBag = DisposeBag()
    
    var playlist: Playlist! {
        didSet {
            playlistItems.accept(playlist.items)
        }
    }
    var playlistObject: PlaylistObject!
    let playlistItems = BehaviorRelay<[Utterance]>(value: [])
}
