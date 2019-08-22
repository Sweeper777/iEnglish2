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
    
    override func viewDidLoad() {
        tableView.dataSource = nil
        
        let observable = playlists.asObservable().map { [PlaylistSection(items: $0)] }
        let datasource = RxTableViewSectionedAnimatedDataSource<PlaylistSection>(configureCell: {
            (datasource, tableView, indexPath, playlist) -> UITableViewCell in
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
            cell.textLabel?.text = playlist.name
            return cell
        })
        observable.bind(to: tableView.rx.items(dataSource: datasource)).disposed(by: disposeBag)
    }
}

struct PlaylistSection : AnimatableSectionModelType, IdentifiableType {
    typealias Identity = String
    var identity: String {
        return ""
    }
    
    typealias Item = Playlist
    
    var items: [Playlist]
    
    init(original: PlaylistSection, items: [Playlist]) {
        self = original
        self.items = items
    }
    
    init(items: [Playlist]) {
        self.items = items
    }
}

extension Playlist : IdentifiableType, Equatable {
    typealias Identity = String
    
    var identity: String { return name }
    
    static func ==(lhs: Playlist, rhs: Playlist) -> Bool {
        return lhs.name == rhs.name
    }
}
