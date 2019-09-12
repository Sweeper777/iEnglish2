import UIKit
import Eureka
import SCLAlertView

class EditPlaylistItemController: FormViewController {

    var utteranceObject: UtteranceObject!
    weak var delegate: EditPlaylistItemControllerDelegate?
    
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
    
    @IBAction func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    
    func showError(_ message: String) {
        let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
        alert.addButton("好", action: {})
        alert.showError("错误!", subTitle: message)
    }
}
