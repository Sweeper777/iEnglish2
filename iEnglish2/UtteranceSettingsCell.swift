import UIKit
import Eureka

final class UtteranceSettingsCell: Cell<UtteranceSettings>, CellType, UtteranceSettingsViewDelegate {
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
        height = { return 293 }
        utteranceSettingsView.delegate = self
        
        row.value = row.value ?? utteranceSettingsView.utteranceSettings
    }
    
    override func update() {
        super.update()
        
        guard let settings = row.value else { return }
        
        utteranceSettingsView.utteranceSettings = settings
    }
    
    func settingsDidChange(utteranceSettingsView: UtteranceSettingsView, newSettings: UtteranceSettings) {
        row.value = newSettings
        row.updateCell()
    }
}
