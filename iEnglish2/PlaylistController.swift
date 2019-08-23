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
        observable.bind(to: tableView.rx.items(dataSource: datasource)).disposed(by: disposeBag)
        
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
