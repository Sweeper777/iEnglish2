import UIKit
import SwiftyButton
import SnapKit

class ViewController: UIViewController {

    @IBOutlet var textField: UITextField!
    @IBOutlet var playButton: PressableButton!
    
    override func viewDidLoad() {
        
        playButton.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalTo(94)
            make.height.equalTo(54)
        }
        
        textField.snp.makeConstraints { (make) in
            make.bottom.equalTo(playButton.snp.top).offset(-8)
            make.left.equalTo(view.safeAreaInsets.left).offset(8)
            make.right.equalTo(view.safeAreaInsets.right).offset(-8)
        }
    }
}

