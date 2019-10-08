import UIKit

@IBDesignable
class CameraTrigger: UIButton {
    
    var pressed = false {
        didSet {
            setNeedsDisplay()
        }
    }
    
}
