import UIKit
import SnapKit
import MediaPlayer
import MarqueeLabel
import BetterSegmentedControl

class NowPlayingController : UIViewController {
    @IBOutlet var blur: UIVisualEffectView!
    @IBOutlet var statusLabel: MarqueeLabel!
    @IBOutlet var utteranceTextView: UITextView!
    @IBOutlet var utteranceTextViewContainer: UIView!
    @IBOutlet var controlButtonsStackView: UIStackView!
    @IBOutlet var previousButton: UIButton!
    @IBOutlet var playPauseButton: UIButton!
    @IBOutlet var nextButton: UIButton!
    @IBOutlet var volumeView: MPVolumeView!
    @IBOutlet var playingModeSegmentedControl: BetterSegmentedControl!
    
    var playlist: Playlist!
    var currentIndex = 0 {
        didSet {
            updateTextViewAndLabel()
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
    
    private func updateTextViewAndLabel() {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let attributes: [NSAttributedString.Key : Any] = [
            .font: UIFont.systemFont(ofSize: 16),
            .paragraphStyle: paragraphStyle
        ]
        
        utteranceTextView?.attributedText = NSAttributedString(string: currentUtterance.string, attributes: attributes)
        
        statusLabel?.text = "正在播放: \(playlist.name) 项目 \(currentIndex + 1) / \(playlist.items.count) (点击此处返回)"
    }
    
    private func setupViews() {
        blur.snp.makeConstraints { (make) in
            make.width.equalToSuperview()
            make.height.equalToSuperview()
            make.center.equalToSuperview()
        }
        utteranceTextViewContainer.layer.masksToBounds = false
        utteranceTextViewContainer.layer.shadowRadius = 5
        utteranceTextViewContainer.layer.shadowColor = UIColor.black.cgColor
        utteranceTextViewContainer.layer.shadowOpacity = 1
        utteranceTextViewContainer.layer.shadowOffset = .zero
        
        updateTextViewAndLabel()
        statusLabel.animationDelay = 0
        
        [previousButton!, playPauseButton!, nextButton!].forEach { (button) in
            button.setImage(button.image(for: .normal)?.withRenderingMode(.alwaysTemplate), for: .highlighted)
            button.tintColor = UIColor(white: 0, alpha: 0.3)
        }
        previousButton.addTarget(self, action: #selector(previousPressed), for: .touchUpInside)
        playPauseButton.addTarget(self, action: #selector(playPausePressed), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextPressed), for: .touchUpInside)
        
        let gestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(backToPlaylist))
        statusLabel.isUserInteractionEnabled = true
        statusLabel.addGestureRecognizer(gestureRecogniser)
        
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
        
        statusLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(utteranceTextViewContainer.snp.top).dividedBy(2)
            make.left.equalTo(view.safeAreaInsets.left).offset(8)
            make.right.equalTo(view.safeAreaInsets.right).offset(-8)
        }
        
        controlButtonsStackView.snp.makeConstraints { (make) in
            make.width.equalTo(utteranceTextViewContainer.snp.width)
            make.centerX.equalToSuperview()
            make.top.equalTo(utteranceTextViewContainer.snp.bottom).offset(22)
        }
        
        volumeView = MPVolumeView()
        volumeView.showsRouteButton = true
        volumeView.showsVolumeSlider = true
        view.addSubview(volumeView)
        
        volumeView.snp.makeConstraints { (make) in
            make.width.equalTo(utteranceTextViewContainer.snp.width)
            make.centerX.equalToSuperview()
            make.top.equalTo(controlButtonsStackView.snp.bottom).offset(14)
            make.height.equalTo(34)
        }
        
        playingModeSegmentedControl.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(volumeView.snp.bottom)
            make.width.equalTo(180)
            make.height.equalTo(40)
        }
        
        let tint = self.view.tintColor!
        playingModeSegmentedControl.segments = [
            LabelSegment(
                text: "None",
                numberOfLines: 0,
                normalTextColor: tint,
                selectedTextColor: .white),
            IconSegment(
                icon: UIImage(named: "repeat-single")!,
                iconSize: CGSize(width: 25, height: 25),
                normalIconTintColor: tint,
                selectedIconTintColor: .white),
            IconSegment(
                icon: UIImage(named: "icons8-repeat_filled")!,
                iconSize: CGSize(width: 25, height: 25),
                normalIconTintColor: tint,
                selectedIconTintColor: .white),
            IconSegment(
                icon: UIImage(named: "icons8-shuffle_filled")!,
                iconSize: CGSize(width: 25, height: 25),
                normalIconTintColor: tint,
                selectedIconTintColor: .white),
        ]
        playingModeSegmentedControl.backgroundColor = .clear
        playingModeSegmentedControl.indicatorViewBackgroundColor = tint
        playingModeSegmentedControl.cornerRadius = 20
    }
    
    override func viewDidLoad() {
        setupViews()
        
        speechSynthesiser.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        playCurrentUtterance()
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
    
    func random() {
        currentIndex = (currentIndex + Int.random(in: 1..<playlist.items.count)) % playlist.items.count
        playCurrentUtterance()
    }
    
    func backToStart() {
        currentIndex = 0
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
        isManuallyStopping = false
        try? AVAudioSession.sharedInstance().setActive(false)
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        if isManuallyStopping {
            try? AVAudioSession.sharedInstance().setActive(false)
            isManuallyStopping = false
            return
        }
        switch playingModeSegmentedControl.index {
        case 1:
            playCurrentUtterance()
        case 2:
            if currentIndex >= playlist.items.count - 1 {
                backToStart()
            } else {
                next()
            }
        case 3:
            random()
        default:
            if currentIndex >= playlist.items.count - 1 {
                try? AVAudioSession.sharedInstance().setActive(false)
                isPlaying = false
            } else {
                next()
            }
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        let attributedString = NSMutableAttributedString(attributedString: utteranceTextView.attributedText)
        attributedString.removeAttribute(NSAttributedString.Key.backgroundColor, range: NSRange(location: 0, length: attributedString.length))
        attributedString.addAttribute(NSAttributedString.Key.backgroundColor, value: UIColor.yellow, range: characterRange)
        utteranceTextView.attributedText = attributedString
        utteranceTextView.scrollRangeToVisible(characterRange)
    }
}
