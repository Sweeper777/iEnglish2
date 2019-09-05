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
    
}
