import UIKit
import Eureka
import SCLAlertView

class PlaylistItemEditorController : FormViewController {
    var utteranceObject: UtteranceObject?
    weak var delegate: PlaylistItemEditorControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        form +++ Section("句子或词语")
            
            <<< TextAreaRow(tagContent) {
                row in
                row.value = utteranceObject?.string ?? ""
            }.cellUpdate({ (cell, row) in
                if #available(iOS 13.0, *) {
                    cell.textView.textColor = .label
                }
            })
        
        form +++ Section("设置")
            
            <<< UtteranceSettingsRow(tagUtteranceSettings) {
                row in
                row.value = utteranceObject?.utterance.settings
        }
        
        if utteranceObject != nil {
            navigationItem.title = "编辑播放列表项目"
        } else {
            navigationItem.title = "新建播放列表项目"
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
        
        func saveChanges() {
            guard let utteranceObject = self.utteranceObject else { return }
            
            try? RealmWrapper.shared.realm.write {
                utteranceObject.string = content
                utteranceObject.rate = settings.rate
                utteranceObject.pitch = settings.pitch
                utteranceObject.volume = settings.volume
                utteranceObject.language = settings.language
            }
            delegate?.didUpdatePlaylistItem(utteranceObject)
        }
        
        func newPlaylist() {
            delegate?.didCreatePlaylistItem(Utterance(string: content, settings: settings))
        }
        
        func close() {
            if utteranceObject != nil {
                saveChanges()
            } else {
                newPlaylist()
            }
            dismiss(animated: true, completion: nil)
        }
        
        let language = detectedLangauge(for: content) ?? "und"
        if !language.starts(with: "en") && content.count > 25 {
            let readableLanguage = Locale.current.localizedString(forLanguageCode: language)
            let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
            alert.addButton("是", action: close)
            alert.addButton("否", action: {})
            alert.showWarning("貌似不是英语?", subTitle: "你似乎输入了\(readableLanguage ?? language), 是否继续?")
        } else {
            close()
        }
        
    }
    
    func showError(_ message: String) {
        let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
        alert.addButton("好", action: {})
        alert.showError("错误!", subTitle: message)
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if traitCollection.verticalSizeClass == .regular && traitCollection.horizontalSizeClass == .regular {
            return .all
        } else {
            return .portrait
        }
    }
}

protocol PlaylistItemEditorControllerDelegate : class {
    func didUpdatePlaylistItem(_ item: UtteranceObject)
    func didCreatePlaylistItem(_ item: Utterance)
}

let tagContent = "content"
let tagUtteranceSettings = "settings"
