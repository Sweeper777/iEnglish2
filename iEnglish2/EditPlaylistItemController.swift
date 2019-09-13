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
                row.value = utteranceObject.string
        }
        
        form +++ Section("设置")
            
            <<< UtteranceSettingsRow(tagUtteranceSettings) {
                row in
                row.value = utteranceObject.utterance.settings
        }
    }
    
    @IBAction func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func done() {
        let values = form.values()
        guard let content = values[tagContent] as? String else {
            showError("请输入句子或词语!")
            return
        }
        
        guard let settings = values[tagUtteranceSettings] as? UtteranceSettings else {
            fatalError()
        }
        
        func saveAndDismiss() {
            try? RealmWrapper.shared.realm.write {
                self.utteranceObject.string = content
                self.utteranceObject.rate = settings.rate
                self.utteranceObject.pitch = settings.pitch
                self.utteranceObject.volume = settings.volume
                self.utteranceObject.language = settings.language
            }
            delegate?.didUpdatePlaylistItem(utteranceObject)
            dismiss(animated: true, completion: nil)
        }
        
    }
    
    func showError(_ message: String) {
        let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
        alert.addButton("好", action: {})
        alert.showError("错误!", subTitle: message)
    }
}
