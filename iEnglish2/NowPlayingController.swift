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
    
    var isManuallyStopping = false
    
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
        playlistNameLabel.text = "正在播放\n\(playlist.name)"
        
        [previousButton!, playPauseButton!, nextButton!].forEach { (button) in
            button.setImage(button.image(for: .normal)?.withRenderingMode(.alwaysTemplate), for: .highlighted)
            button.tintColor = UIColor(white: 0, alpha: 0.3)
        }
        previousButton.addTarget(self, action: #selector(previousPressed), for: .touchUpInside)
        playPauseButton.addTarget(self, action: #selector(playPausePressed), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextPressed), for: .touchUpInside)
        
        let gestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(backToPlaylist))
        playlistNameLabel.isUserInteractionEnabled = true
        playlistNameLabel.addGestureRecognizer(gestureRecogniser)
        
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
    
    @objc func backToPlaylist() {
        isManuallyStopping = speechSynthesiser.stopSpeaking(at: .immediate)
        try? AVAudioSession.sharedInstance().setActive(false)
        isPlaying = false
        dismiss(animated: true, completion: nil)
    }
    
    func playCurrentUtterance() {
        isManuallyStopping = speechSynthesiser.stopSpeaking(at: .immediate)
        speechSynthesiser.speak(currentUtterance.avUtterance)
        isPlaying = true
    }
    
    func continuePlaying() {
        speechSynthesiser.continueSpeaking()
        isPlaying = true
    }
    
    func pause() {
        speechSynthesiser.pauseSpeaking(at: .immediate)
        isPlaying = false
    }
    
    func next() {
        currentIndex += 1
        playCurrentUtterance()
    }
    
    func previous() {
        currentIndex -= 1
        playCurrentUtterance()
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
        print("Cancel!")
//            isManuallyStopping = false
        try? AVAudioSession.sharedInstance().setActive(false)
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        print("Finish!")
        if currentIndex >= playlist.items.count - 1 {
            try? AVAudioSession.sharedInstance().setActive(false)
            isPlaying = false
        } else {
            next()
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        let attributedString = NSMutableAttributedString(attributedString: utteranceTextView.attributedText)
        attributedString.removeAttribute(NSAttributedString.Key.backgroundColor, range: NSRange(location: 0, length: attributedString.length))
        attributedString.addAttribute(NSAttributedString.Key.backgroundColor, value: UIColor.yellow, range: characterRange)
        utteranceTextView.attributedText = attributedString
    }
}
