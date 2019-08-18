import UIKit

class UtteranceSettingsView: UIView {
    @IBOutlet var contentView: UIView!
    
    @IBOutlet var rateSlider: UISlider!
    @IBOutlet var pitchSlider: UISlider!
    @IBOutlet var volumeSlider: UISlider!
    @IBOutlet var languageSegmentedControl: UISegmentedControl!
    
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
    }
}
