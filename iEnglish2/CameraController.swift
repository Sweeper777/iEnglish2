import UIKit
import AACameraView

class CameraController: UIViewController {
    
    
    @IBOutlet var cameraTrigger: CameraTrigger!
    
    @IBOutlet var cameraView: AACameraView!
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cameraView.stopSession()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UIImagePickerController.isCameraDeviceAvailable(.front) || UIImagePickerController.isCameraDeviceAvailable(.rear) {
            cameraView.startSession()
        }
    }
}
