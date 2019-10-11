import UIKit
import Firebase
import EZLoadingActivity

class CameraResultsController: UITableViewController {
    
    var image: UIImage!
    
    var textBlocks: [VisionTextBlock]?
    var textBlocksSet = false
    
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
}
