import UIKit
import AVFoundation

class UtteranceSettingsView: UIView {
    @IBOutlet var contentView: UIView!
    
    @IBOutlet var rateSlider: UISlider!
    @IBOutlet var pitchSlider: UISlider!
    @IBOutlet var volumeSlider: UISlider!
    @IBOutlet var languageSegmentedControl: UISegmentedControl!
    
    var utteranceSettings: UtteranceSettings {
        get {
            return UtteranceSettings(
                rate: rateSlider.value,
                pitch: pitchSlider.value,
                volume: volumeSlider.value,
                language: languageSegmentedControl.selectedSegmentIndex == 1 ? "en-US" : "en-GB")
        }
        set {
            rateSlider.value = newValue.rate
            pitchSlider.value = newValue.pitch
            volumeSlider.value = newValue.volume
            languageSegmentedControl.selectedSegmentIndex = newValue.language == "en-US" ? 1 : 0
        }
    }
    
    weak var delegate: UtteranceSettingsViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("UtteranceSettingsView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        rateSlider.minimumValue = AVSpeechUtteranceMinimumSpeechRate
        rateSlider.maximumValue = AVSpeechUtteranceMaximumSpeechRate
        rateSlider.value = AVSpeechUtteranceDefaultSpeechRate
        
        pitchSlider.minimumValue = 0.5
        pitchSlider.maximumValue = 2
        pitchSlider.value = 1
        
        volumeSlider.minimumValue = 0
        volumeSlider.maximumValue = 1
        volumeSlider.value = 1
        
        rateSlider.addTarget(self, action: #selector(controlChanged), for: .valueChanged)
        pitchSlider.addTarget(self, action: #selector(controlChanged), for: .valueChanged)
        volumeSlider.addTarget(self, action: #selector(controlChanged), for: .valueChanged)
        languageSegmentedControl.addTarget(self, action: #selector(controlChanged), for: .valueChanged)
    }
    
    @objc func controlChanged() {
        delegate?.settingsDidChange(utteranceSettingsView: self, newSettings: utteranceSettings)
    }
}

protocol UtteranceSettingsViewDelegate : class {
    func settingsDidChange(utteranceSettingsView: UtteranceSettingsView, newSettings: UtteranceSettings)
}
