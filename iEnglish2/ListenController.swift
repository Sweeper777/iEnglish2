import UIKit
import SwiftyButton
import SnapKit
import AVFoundation
import RealmSwift
import SCLAlertView

class ListenController: UIViewController {

    @IBOutlet var textField: UITextField!
    @IBOutlet var playButton: PressableButton!
    @IBOutlet var utteranceSettingsView: UtteranceSettingsView!
    
    let synthesiser = AVSpeechSynthesizer()
    
    override func viewDidLoad() {
        
        playButton.addTarget(self, action: #selector(playPress), for: .touchUpInside)
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.isTranslucent = false
        keyboardToolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .done, target: textField, action: #selector(UITextField.resignFirstResponder)),
        ]
        keyboardToolbar.sizeToFit()
        textField.inputAccessoryView = keyboardToolbar
    }
    
    func play() {
        let utterance = Utterance(string: textField.text ?? "", settings: utteranceSettingsView.utteranceSettings).avUtterance
        synthesiser.speak(utterance)
    }
    
    @objc func playPress() {
        let language = textField.text.flatMap(detectedLangauge) ?? "und"
        if !language.starts(with: "en") && textField.text!.count > 25 {
            let readableLanguage = Locale.current.localizedString(forLanguageCode: language)
            let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
            alert.addButton("是", action: play)
            alert.addButton("否", action: {})
            alert.showWarning("貌似不是英语?", subTitle: "你似乎输入了\(readableLanguage ?? language), 要继续播放吗?")
        } else {
            play()
        }
    }
}

