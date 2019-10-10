import UIKit
import AACameraView

class CameraController: UIViewController {
    
    var hasImageBeenCaptured = false
    
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
    
    @IBAction func triggerCamera() {
        if !hasImageBeenCaptured {
            cameraView.captureImage()
            hasImageBeenCaptured = true
            cameraView.stopSession()
        }
    }
    
    @IBAction func photoLibraryPress() {
        let imagePicker = UIImagePickerController(rootViewController: self)
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.mediaTypes = ["public.image"]
        present(imagePicker, animated: true, completion: nil)
    }
}
