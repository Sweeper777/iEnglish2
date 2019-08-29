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
    
    override func viewDidLoad() {
        tableView.dataSource = nil
        tableView.tableFooterView = UIView()
        
        tableView.emptyDataSetView { (view) in
            view.titleLabelString(NSAttributedString(string: "什么也没有"))
            view.verticalOffset(-70)
            view.image(UIImage(named: "icons8-personal_video_recorder_menu"))
            view.detailLabelString(NSAttributedString(string: "点击\"+\"来把项目加入到播放列表里吧!"))
            view.shouldBeForcedToDisplay(false)
            view.shouldDisplay(true)
        }
        
//        let observable = playlists.asObservable().map { [PlaylistSection(items: $0)] }
//        let datasource = RxTableViewSectionedAnimatedDataSource<PlaylistSection>(configureCell: {
//            (datasource, tableView, indexPath, playlist) -> UITableViewCell in
//            let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
//            cell.textLabel?.text = playlist.name
//            return cell
//        })
//        datasource.canEditRowAtIndexPath = { _, _ in return true }
//        observable.bind(to: tableView.rx.items(dataSource: datasource)).disposed(by: disposeBag)
        
//        tableView.rx.itemDeleted.subscribe(onNext: {
//            [weak self] indexPath in
//            guard let `self` = self else { return }
//            let playlistObjectToDelete = self.playlistObjects[indexPath.row]
//            try? RealmWrapper.shared.realm.write {
//                RealmWrapper.shared.realm.delete(playlistObjectToDelete)
//            }
//            self.playlists.accept(self.playlistObjects.map { $0.playlist })
//        }).disposed(by: disposeBag)
//
//        playlists.accept(playlistObjects.map { $0.playlist })
        
        navigationItem.rightBarButtonItems?.insert(editButtonItem, at: 0)
        
//        tableView.rx.modelSelected(Playlist.self).subscribe(onNext: {
//            [weak self] playlist in
//            guard let index = self?.playlists.value.firstIndex(of: playlist) else { return }
//            self?.performSegue(withIdentifier: "showPlaylist", sender: self?.playlistObjects[index])
//        }).disposed(by: disposeBag)
        
        playlist = playlistObject.playlist
    }
}

struct UtteranceSection : AnimatableSectionModelType, IdentifiableType {
    typealias Identity = String
    var identity: String {
        return ""
    }
    
    typealias Item = Utterance
    
    var items: [Utterance]
    
    init(original: UtteranceSection, items: [Utterance]) {
        self = original
        self.items = items
    }
    
    init(items: [Utterance]) {
        self.items = items
    }
}
