import UIKit
import Eureka
import SCLAlertView

class NewPlaylistItemController: FormViewController {
    weak var delegate: NewPlaylistItemControllerDelegate?
    
}

protocol NewPlaylistItemControllerDelegate : class {
    func didCreatePlaylistItem(_ item: Utterance)
}

let tagContent = "content"
let tagUtteranceSettings = "settings"
