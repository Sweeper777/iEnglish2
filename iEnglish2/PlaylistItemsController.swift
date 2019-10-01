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
        navigationItem.title = playlistObject.name
        
        tableView.emptyDataSetView { (view) in
            view.titleLabelString(NSAttributedString(string: "什么也没有"))
            view.verticalOffset(-70)
            view.image(UIImage(named: "icons8-personal_video_recorder_menu"))
            view.detailLabelString(NSAttributedString(string: "点击\"+\"来把项目加入到播放列表里吧!"))
            view.shouldBeForcedToDisplay(false)
            view.shouldDisplay(true)
        }
        
        let observable = playlistItems.asObservable().map { [UtteranceSection(items: $0)] }
        let datasource = RxTableViewSectionedAnimatedDataSource<UtteranceSection>(configureCell: {
            (datasource, tableView, indexPath, utterance) -> UITableViewCell in
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
            cell.textLabel?.text = utterance.string
            return cell
        })
        datasource.canEditRowAtIndexPath = { _, _ in return true }
        datasource.canMoveRowAtIndexPath =  { _, _ in return true }
        
        observable.bind(to: tableView.rx.items(dataSource: datasource)).disposed(by: disposeBag)
        
        tableView.rx.itemDeleted.subscribe(onNext: {
            [weak self] indexPath in
            guard let `self` = self else { return }
            let utteranceObjectToDelete = self.playlistObject.items[indexPath.row]
            try? RealmWrapper.shared.realm.write {
                RealmWrapper.shared.realm.delete(utteranceObjectToDelete)
            }
            self.playlist = self.playlistObject.playlist
        }).disposed(by: disposeBag)
        
        tableView.rx.itemMoved.subscribe(onNext: {
            [weak self] from, to in
            guard let `self` = self else { return }
            try? RealmWrapper.shared.realm.write {
                let utteranceMoved = self.playlistObject.items[from.row]
                self.playlistObject.items.remove(at: from.row)
                self.playlistObject.items.insert(utteranceMoved, at: to.row)
            }
            self.playlist = self.playlistObject.playlist
        }).disposed(by: disposeBag)
        
        tableView.rx.itemSelected.subscribe(onNext: {
            [weak self] indexPath in
            self?.tableView.deselectRow(at: indexPath, animated: true)
            self?.performSegue(withIdentifier: "playPlaylist", sender: indexPath.row)
        }).disposed(by: disposeBag)
        
        navigationItem.rightBarButtonItems?.insert(editButtonItem, at: 0)
        
        playlist = playlistObject.playlist
    }
    
    @IBAction func newPlaylist() {
        performSegue(withIdentifier: "showPlaylistItemEditor", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = (segue.destination as? UINavigationController)?.topViewController as? PlaylistItemEditorController,
            let index = sender as? Int {
            vc.utteranceObject = playlistObject.items[index]
            vc.delegate = self
        } else if let vc = segue.destination as? NowPlayingController, let startingIndex = sender as? Int {
            vc.playlist = playlist
            vc.currentIndex = startingIndex
        } else if let vc = (segue.destination as? UINavigationController)?.topViewController as? PlaylistItemEditorController {
            vc.delegate = self
        }
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        performSegue(withIdentifier: "showPlaylistItemEditor", sender: indexPath.row)
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if traitCollection.verticalSizeClass == .regular && traitCollection.horizontalSizeClass == .regular {
            return .all
        } else {
            return .portrait
        }
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

extension PlaylistItemsController : PlaylistItemEditorControllerDelegate {
    func didCreatePlaylistItem(_ item: Utterance) {
        try? RealmWrapper.shared.realm.write {
            self.playlistObject.items.append(UtteranceObject(from: item))
        }
        playlist = playlistObject.playlist
    }
    func didUpdatePlaylistItem(_ item: UtteranceObject) {
        playlist = playlistObject.playlist
    }
}

extension Utterance : IdentifiableType, Equatable {
    typealias Identity = String
    
    var identity: String { return string }
    
    static func ==(lhs: Utterance, rhs: Utterance) -> Bool {
        return lhs.string == rhs.string
    }
}
