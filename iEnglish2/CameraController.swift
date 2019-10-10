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
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            let alert = UIAlertController(title: "错误", message: "无法查看照片图库", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        let imagePicker = UIImagePickerController(rootViewController: self)
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.mediaTypes = ["public.image"]
        present(imagePicker, animated: true, completion: nil)
    }
}

extension CameraController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
    }
}

