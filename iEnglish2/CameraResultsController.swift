import UIKit
import Firebase
import EZLoadingActivity
import RxSwift
import RxCocoa
import SCLAlertView

class CameraResultsController: UITableViewController {
    @IBOutlet var playButton: UIBarButtonItem!
    @IBOutlet var addButton: UIBarButtonItem!
    
    var image: UIImage!
    
    var textBlocks: [String]?
    var textBlocksSet = false
    var selectedBlockIndices = Set<Int>() {
        didSet {
            selectedBlockIndicesRelay.accept(selectedBlockIndices)
        }
    }
    var selectedBlockIndicesRelay: BehaviorRelay<Set<Int>> = BehaviorRelay(value: [])
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        let observable = selectedBlockIndicesRelay.asObservable().map { !$0.isEmpty }
        observable.bind(to: playButton.rx.isEnabled).disposed(by: disposeBag)
        observable.bind(to: addButton.rx.isEnabled).disposed(by: disposeBag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !textBlocksSet {
            textBlocksSet = true
            EZLoadingActivity.Settings.FailText = "失败!"
            EZLoadingActivity.Settings.SuccessText = "成功!"
            EZLoadingActivity.show("加载中...", disableUI: true)
            let vision = Vision.vision()
            let textRecognizer = vision.onDeviceTextRecognizer()
            let vImage = VisionImage(image: image)
            textRecognizer.process(vImage) { [weak self] (result, error) in
                guard error == nil, let result = result else {
                    EZLoadingActivity.hide(false, animated: true)
                    return
                }
                self?.textBlocks = result.blocks.map { $0.text.replacingOccurrences(of: "\n", with: " ") }
                EZLoadingActivity.hide(true, animated: true)
                self?.tableView.reloadData()
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "检测到的文字"
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return textBlocks?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.textLabel?.text = textBlocks![indexPath.row]
        cell.textLabel?.numberOfLines = 0
        cell.accessoryType = selectedBlockIndices.contains(indexPath.row) ?
            .checkmark : .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedBlockIndices.formSymmetricDifference([indexPath.row])
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    func generatePlaylistFromSelectedBlocks() -> Playlist {
        let selectedTexts = selectedBlockIndices.sorted().map { textBlocks![$0] }
        let utterances = selectedTexts.map(Utterance.init)
        let playlist = Playlist(items: utterances, name: "扫描结果")
        return playlist
    }
    
    @IBAction func playButtonPress(_ sender: Any) {
        performSegue(withIdentifier: "play", sender: generatePlaylistFromSelectedBlocks())
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? NowPlayingController, let playlist = sender as? Playlist {
            vc.playlist = playlist
            vc.currentIndex = 0
        }
        if let vc = (segue.destination as? UINavigationController)?.topViewController as? PlaylistSelectorController {
            vc.delegate = self
        }
    }
    
    @IBAction func addButtonPress(_ sender: Any) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "加到新播放列表", style: .default, handler: addToNewPlaylistPress(action:)))
        actionSheet.addAction(UIAlertAction(title: "加到现有的播放列表", style: .default, handler: addToExistingPlaylistPress(action:)))
        actionSheet.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        actionSheet.popoverPresentationController?.barButtonItem = addButton
        present(actionSheet, animated: true, completion: nil)
    }
    
    func addToNewPlaylistPress(action: UIAlertAction) {
        func validatePlaylistName(_ name: String?) -> Bool {
            if (name?.trimmed()).isNilOrEmpty {
                let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
                alert.addButton("确定", action: {})
                alert.showWarning("播放列表名不能为空!")
                return false
            }
            let playlistObjects = RealmWrapper.shared.playlists!
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
            let playlist = self.generatePlaylistFromSelectedBlocks()
            let playlistObject = PlaylistObject(from: playlist)
            playlistObject.name = textfield.text!
            try? RealmWrapper.shared.realm.write {
                RealmWrapper.shared.realm.add(playlistObject)
            }
            self.navigationController?.popViewController(animated: true)
        }
        prompt.addButton("取消", action: {})
        prompt.showEdit("输入播放列表名:")
    }
    
    func addToExistingPlaylistPress(action: UIAlertAction) {
        if RealmWrapper.shared.playlists.isEmpty {
            let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
            alert.addButton("确定", action: {})
            alert.showError("错误", subTitle: "你没有任何播放列表!")
            return
        }
        performSegue(withIdentifier: "showPlaylistSelector", sender: nil)
    }
}

extension CameraResultsController : PlaylistSelectorControllerDelegate {
    func didSelect(playlistObject: PlaylistObject) {
        let playlist = generatePlaylistFromSelectedBlocks()
        let utteranceObjects = playlist.items.map(UtteranceObject.init)
        try? RealmWrapper.shared.realm.write {
            playlistObject.items.append(objectsIn: utteranceObjects)
        }
        self.navigationController?.popViewController(animated: true)
    }
}
