import UIKit

@IBDesignable
class CameraTrigger: UIButton {
    
    var pressed = false {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        (UIApplication.shared.delegate as? AppDelegate).
        let outerCircle = UIBezierPath(ovalIn: bounds.insetBy(dx: 1.5, dy: 1.5))
        UIColor.white.setStroke()
        outerCircle.lineWidth = 3
        outerCircle.stroke()
        
        let inset = pressed ? 5.9.f : 5.f;
        let innerCircle = UIBezierPath(ovalIn: bounds.insetBy(dx: inset, dy: inset))
        UIColor.white.setFill()
        innerCircle.fill()
    }
}
