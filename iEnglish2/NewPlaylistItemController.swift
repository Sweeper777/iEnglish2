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
    
}

protocol NewPlaylistItemControllerDelegate : class {
    func didCreatePlaylistItem(_ item: Utterance)
}

let tagContent = "content"
let tagUtteranceSettings = "settings"
