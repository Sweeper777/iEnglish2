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
            utteranceTextView?.attributedText = NSAttributedString(string: currentUtterance.string)
        }
    }
    
    var currentUtterance: Utterance {
        return playlist.items[currentIndex]
    }
    
    let speechSynthesiser = AVSpeechSynthesizer()
    
    private func setupViews() {
        blur.snp.makeConstraints { (make) in
            make.width.equalToSuperview()
            make.height.equalToSuperview()
        }
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
