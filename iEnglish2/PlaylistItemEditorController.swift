import UIKit
import Eureka
import SCLAlertView

class PlaylistItemEditorController : FormViewController {
    var utteranceObject: UtteranceObject?
    
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
    
    @IBAction func done() {
        let values = form.values()
        guard let content = values[tagContent] as? String else {
            showError("请输入句子或词语!")
            return
        }
        
        guard let settings = values[tagUtteranceSettings] as? UtteranceSettings else {
            fatalError()
        }
        
        
        let language = detectedLangauge(for: content) ?? "und"
        if !language.starts(with: "en") && content.count > 25 {
            let readableLanguage = Locale.current.localizedString(forLanguageCode: language)
            let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
            alert.addButton("是", action: saveAndDismiss)
            alert.addButton("否", action: {})
            alert.showWarning("貌似不是英语?", subTitle: "你似乎输入了\(readableLanguage ?? language), 是否继续?")
        } else {
            if utteranceObject != nil {
                saveAndDismiss()
            } else {
                callDelegateAndDismiss()
            }
        }
        
    }
    
    func showError(_ message: String) {
        let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
        alert.addButton("好", action: {})
        alert.showError("错误!", subTitle: message)
    }
}

protocol PlaylistItemEditorControllerDelegate : class {
    func didUpdatePlaylistItem(_ item: UtteranceObject)
    func didCreatePlaylistItem(_ item: Utterance)
}

