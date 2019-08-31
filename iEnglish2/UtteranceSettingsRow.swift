import UIKit
import Eureka

final class UtteranceSettingsRow: Row<UtteranceSettingsCell>, RowType {
    required init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<UtteranceSettingsCell>(nibName: "UtteranceSettingsCell")
    }
}
