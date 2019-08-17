import UIKit
import SwiftyButton
import SnapKit
import AVFoundation

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
        
        playButton.addTarget(self, action: #selector(playPress), for: .touchUpInside)
    }
    
    func play() {
        let synthesiser = AVSpeechSynthesizer()
        let utterance = AVSpeechUtterance(string: textField.text ?? "")
        utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
        synthesiser.speak(utterance)
    }
    
    @objc func playPress() {
            play()
    }
}

