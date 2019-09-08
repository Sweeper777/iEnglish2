import UIKit
import SnapKit
import MediaPlayer

class NowPlayingController : UIViewController {
    @IBOutlet var blur: UIVisualEffectView!
    @IBOutlet var playlistNameLabel: UILabel!
    @IBOutlet var utteranceTextView: UITextView!
    @IBOutlet var utteranceTextViewContainer: UIView!
    @IBOutlet var controlButtonsStackView: UIStackView!
    @IBOutlet var previousButton: UIButton!
    @IBOutlet var playPauseButton: UIButton!
    @IBOutlet var nextButton: UIButton!
    @IBOutlet var volumeView: MPVolumeView!
    
    var playlist: Playlist!
    var currentIndex = 0 {
        didSet {
            updateTextView()
        }
    }
    
    var currentUtterance: Utterance {
        return playlist.items[currentIndex]
    }
    
    var isPlaying = false {
        didSet {
            if isPlaying {
                playPauseButton.setImage(UIImage(named: "icons8-pause_filled"), for: .normal)
                playPauseButton.setImage(UIImage(named: "icons8-pause_filled")?.withRenderingMode(.alwaysTemplate), for: .highlighted)
            } else {
                playPauseButton.setImage(UIImage(named: "icons8-play_filled"), for: .normal)
                playPauseButton.setImage(UIImage(named: "icons8-play_filled")?.withRenderingMode(.alwaysTemplate), for: .highlighted)
            }
        }
    }
    
    let speechSynthesiser = AVSpeechSynthesizer()
    
    private func updateTextView() {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let attributes: [NSAttributedString.Key : Any] = [
            .font: UIFont.systemFont(ofSize: UIFont.systemFontSize),
            .paragraphStyle: paragraphStyle
        ]
        
        utteranceTextView?.attributedText = NSAttributedString(string: currentUtterance.string, attributes: attributes)
    }
    
    private func setupViews() {
        blur.snp.makeConstraints { (make) in
            make.width.equalToSuperview()
            make.height.equalToSuperview()
        }
        utteranceTextViewContainer.layer.masksToBounds = false
        utteranceTextViewContainer.layer.shadowRadius = 5
        utteranceTextViewContainer.layer.shadowColor = UIColor.black.cgColor
        utteranceTextViewContainer.layer.shadowOpacity = 1
        utteranceTextViewContainer.layer.shadowOffset = .zero
        
        updateTextView()
        
        [previousButton!, playPauseButton!, nextButton!].forEach { (button) in
            button.setImage(button.image(for: .normal)?.withRenderingMode(.alwaysTemplate), for: .highlighted)
            button.tintColor = UIColor(white: 0, alpha: 0.3)
        }
        previousButton.addTarget(self, action: #selector(previousPressed), for: .touchUpInside)
        playPauseButton.addTarget(self, action: #selector(playPausePressed), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextPressed), for: .touchUpInside)
        
        
        utteranceTextView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.height.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        utteranceTextViewContainer.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.height.equalTo(utteranceTextViewContainer.snp.width)
            make.width.equalToSuperview().multipliedBy(0.75)
        }
        
        playlistNameLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(utteranceTextViewContainer.snp.top).dividedBy(2)
            make.left.equalTo(view.safeAreaInsets.left).offset(8)
            make.right.equalTo(view.safeAreaInsets.right).offset(-8)
        }
        
        controlButtonsStackView.snp.makeConstraints { (make) in
            make.width.equalTo(utteranceTextViewContainer.snp.width)
            make.centerX.equalToSuperview()
            make.top.equalTo(utteranceTextViewContainer.snp.bottom).offset(22)
        }
        
        volumeView.snp.makeConstraints { (make) in
            make.width.equalTo(utteranceTextViewContainer.snp.width)
            make.centerX.equalToSuperview()
            make.top.equalTo(controlButtonsStackView.snp.bottom).offset(14)
        }
    }
    
    override func viewDidLoad() {
        setupViews()
        
        speechSynthesiser.delegate = self
    }
    
    @objc func previousPressed() {
        guard currentIndex > 0 else { return }
        previous()
    }
    
    @objc func nextPressed() {
        guard currentIndex < playlist.items.count - 1 else { return }
        next()
    }
    
    @objc func playPausePressed() {
        if isPlaying {
            pause()
        } else {
            if speechSynthesiser.isPaused {
                continuePlaying()
            } else {
                playCurrentUtterance()
            }
        }
    }
    
}

extension NowPlayingController : AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        try? AVAudioSession.sharedInstance().setActive(true)
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        try? AVAudioSession.sharedInstance().setActive(false)
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
        try? AVAudioSession.sharedInstance().setActive(true)
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        try? AVAudioSession.sharedInstance().setActive(false)
    }
}
