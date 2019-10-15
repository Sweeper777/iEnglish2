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
    
    var textBlocks: [VisionTextBlock]?
    var textBlocksSet = false
    var selectedBlockIndices = Set<Int>() {
        didSet {
            selectedBlockIndicesRelay.accept(selectedBlockIndices)
        }
    }
    var selectedBlockIndicesRelay: BehaviorRelay<Set<Int>> = BehaviorRelay(value: [])
    let disposeBag = DisposeBag()
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !textBlocksSet {
            textBlocksSet = true
            EZLoadingActivity.Settings.FailText = "失败!"
            EZLoadingActivity.show("加载中...", disableUI: true)
            let vision = Vision.vision()
            let textRecognizer = vision.onDeviceTextRecognizer()
            let vImage = VisionImage(image: image)
            textRecognizer.process(vImage) { [weak self] (result, error) in
                guard error == nil, let result = result else {
                    EZLoadingActivity.hide(false, animated: true)
                    return
                }
                self?.textBlocks = result.blocks
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
        cell.textLabel?.text = textBlocks![indexPath.row].text
        return cell
    }
}
