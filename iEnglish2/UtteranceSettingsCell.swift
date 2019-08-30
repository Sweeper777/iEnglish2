import UIKit
import Eureka

final class UtteranceSettingsCell: Cell<UtteranceSettings>, CellType {
    @IBOutlet var utteranceSettingsView: UtteranceSettingsView!
    
    required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func setup() {
        super.setup()
        selectionStyle = .none
        
        // specify the desired height for our cell
        height = { return 293 }
    }
}
