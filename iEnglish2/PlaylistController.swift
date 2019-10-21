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
        tableView.tableFooterView = UIView()
        
        tableView.emptyDataSetView { (view) in
            view.titleLabelString(NSAttributedString(string: "什么也没有"))
            view.verticalOffset(-70)
            view.image(UIImage(named: "icons8-personal_video_recorder_menu"))
            view.detailLabelString(NSAttributedString(string: "点击\"+\"来新建播放列表吧!"))
            view.shouldBeForcedToDisplay(false)
            view.shouldDisplay(true)
        }
        
        playlistObjects = RealmWrapper.shared.playlists
        
        let observable = playlists.asObservable().map { [PlaylistSection(items: $0)] }
        let datasource = RxTableViewSectionedAnimatedDataSource<PlaylistSection>(configureCell: {
            (datasource, tableView, indexPath, playlist) -> UITableViewCell in
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
            cell.textLabel?.text = playlist.name
            return cell
        })
        datasource.canEditRowAtIndexPath = { _, _ in return true }
        observable.bind(to: tableView.rx.items(dataSource: datasource)).disposed(by: disposeBag)
        
        tableView.rx.itemDeleted.subscribe(onNext: {
            [weak self] indexPath in
            guard let `self` = self else { return }
            let playlistObjectToDelete = self.playlistObjects[indexPath.row]
            try? RealmWrapper.shared.realm.write {
                RealmWrapper.shared.realm.delete(playlistObjectToDelete)
            }
            self.playlists.accept(self.playlistObjects.map { $0.playlist })
        }).disposed(by: disposeBag)
        
        playlists.accept(playlistObjects.map { $0.playlist })
        
        navigationItem.rightBarButtonItems?.insert(editButtonItem, at: 0)
        
        tableView.rx.modelSelected(Playlist.self).subscribe(onNext: {
            [weak self] playlist in
            guard let index = self?.playlists.value.firstIndex(of: playlist) else { return }
            self?.performSegue(withIdentifier: "showPlaylist", sender: self?.playlistObjects[index])
        }).disposed(by: disposeBag)
        
        playlists.asObservable()
            .map { $0.isEmpty }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] _ in self?.tableView.reloadEmptyDataSet() })
            .disposed(by: disposeBag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        playlists.accept(playlistObjects.map { $0.playlist })
    }
    
    @IBAction func addPress() {
        func validatePlaylistName(_ name: String?) -> Bool {
            if (name?.trimmed()).isNilOrEmpty {
                let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
                alert.addButton("确定", action: {})
                alert.showWarning("播放列表名不能为空!")
                return false
            }
            if playlistObjects.filter(NSPredicate(format: "name == %@", name!)).count > 0 {
                let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
                alert.addButton("确定", action: {})
                alert.showWarning("播放列表名不能重复!")
                return false
            }
            return true
        }
        
        let prompt = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
        let textfield = prompt.addTextField("播放列表名")
        textfield.backgroundColor = .white
        textfield.textColor = .black
        prompt.addButton("确定") { [weak self] in
            guard let `self` = self else { return }
            guard validatePlaylistName(textfield.text) else { return }
            let playlist = PlaylistObject()
            playlist.name = textfield.text!
            try? RealmWrapper.shared.realm.write {
                RealmWrapper.shared.realm.add(playlist)
            }
            self.playlists.accept(self.playlistObjects.map { $0.playlist })
        }
        prompt.addButton("取消", action: {})
        prompt.showEdit("输入播放列表名:")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? PlaylistItemsController, let playlistObject = sender as? PlaylistObject {
            vc.playlistObject = playlistObject
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if traitCollection.verticalSizeClass == .regular && traitCollection.horizontalSizeClass == .regular {
            return .all
        } else {
            return .portrait
        }
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
