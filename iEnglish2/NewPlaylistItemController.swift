import UIKit
import Eureka
import SCLAlertView

class NewPlaylistItemController: FormViewController {
    weak var delegate: NewPlaylistItemControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        form +++ Section("句子或词语")
        
        <<< TextAreaRow(tagContent) {
            row in
        }
        
        form +++ Section("设置")
        
        <<< UtteranceSettingsRow(tagUtteranceSettings) {
            row in
        }
    }
    
    
    func showError(_ message: String) {
        let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
        alert.addButton("好", action: {})
        alert.showError("错误!", subTitle: message)
    }
}

protocol NewPlaylistItemControllerDelegate : class {
    func didCreatePlaylistItem(_ item: Utterance)
}

let tagContent = "content"
let tagUtteranceSettings = "settings"
