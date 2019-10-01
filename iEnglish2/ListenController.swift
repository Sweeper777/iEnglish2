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
    var shouldHighlight = true
    
    override func viewDidLoad() {
        synthesiser.delegate = self
        playButton.addTarget(self, action: #selector(playPress), for: .touchUpInside)
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.isTranslucent = false
        keyboardToolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .done, target: textField, action: #selector(UITextField.resignFirstResponder)),
        ]
        keyboardToolbar.sizeToFit()
        textField.inputAccessoryView = keyboardToolbar
        textField.attributedText = NSAttributedString(string: "")
        textField.delegate = self
    }
    
    func play() {
        let utterance = Utterance(string: textField.text ?? "", settings: utteranceSettingsView.utteranceSettings).avUtterance
        synthesiser.speak(utterance)
    }
    
    @objc func playPress() {
        view.endEditing(true)
        shouldHighlight = true
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
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if traitCollection.verticalSizeClass == .regular && traitCollection.horizontalSizeClass == .regular {
            return .all
        } else {
            return .portrait
        }
    }
}

extension ListenController : AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        if shouldHighlight {
            let attributedString = NSMutableAttributedString(attributedString: textField.attributedText!)
            attributedString.removeAttribute(NSAttributedString.Key.backgroundColor, range: NSRange(location: 0, length: attributedString.length))
            attributedString.addAttribute(NSAttributedString.Key.backgroundColor, value: UIColor.yellow, range: characterRange)
            textField.attributedText = attributedString
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        let attributedString = NSMutableAttributedString(attributedString: textField.attributedText!)
        attributedString.removeAttribute(NSAttributedString.Key.backgroundColor, range: NSRange(location: 0, length: attributedString.length))
        textField.attributedText = attributedString
    }
}

extension ListenController : UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        shouldHighlight = false
        let attributedString = NSMutableAttributedString(attributedString: textField.attributedText!)
        attributedString.removeAttribute(NSAttributedString.Key.backgroundColor, range: NSRange(location: 0, length: attributedString.length))
        textField.attributedText = attributedString
    }
}
