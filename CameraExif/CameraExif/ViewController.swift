import UIKit
import Photos
import CryptoSwift
import SwiftyRSA

class ViewController: UIViewController {

    @IBOutlet weak var exifImageView: UIImageView!
    @IBOutlet weak var exifImageDataLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func clickedEncryptButton(_ sender: Any) {
        var str : String = self.exifImageDataLabel.text as! String ?? ""
        
        let publicKey = try! PublicKey(pemNamed: "key.pem")
        let clear = try! ClearMessage(string: str, using: .utf8)
        let encrypted = try! clear.encrypted(with: publicKey, padding: .PKCS1)

        let data = encrypted.data
        let base64String = encrypted.base64String
        
    }
    
    @IBAction func buttonClicked(_ sender: Any) {
        let alert = UIAlertController()
        alert.addAction(UIAlertAction(title: "사진 앨범", style: .default, handler: { _ in self.galleryButtonClicked() }))
        alert.addAction(UIAlertAction(title: "카메라", style: .default, handler: { _ in self.cameraButtonClicked() }))
        alert.addAction(UIAlertAction(title: "취소", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    func makeImagePicker(by sourceType: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = sourceType
        imagePicker.modalPresentationStyle = .fullScreen
        present(imagePicker, animated: true, completion: nil)
        
        exifImageDataLabel.text = "사진의 날짜 데이터가 없습니다."
    }
    
    func galleryButtonClicked() {
        makeImagePicker(by: .photoLibrary)
    }
    
    func cameraButtonClicked() {
        makeImagePicker(by: .camera)
    }
    
    func AES(str: String){
        let key: String = "0123456789012345"
        //let plain :NSData = str.data(using: String.Encoding)
    }
    
}

extension ViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else { return }
        exifImageView.image = image
        if let date = self.getCreateDate(by: info) {
            print("확인용")
            print(date)
            self.exifImageDataLabel.text = date.toString()
        }
        dismiss(animated: true, completion: nil)
    }
    
    func getCreateDate(by info: [UIImagePickerController.InfoKey : Any]) -> Date? {
        guard let asset = info[.phAsset] as? PHAsset else {
            return getExifDate(by: info)
        }
        return asset.creationDate
    }
    
    func getExifDate(by info: [UIImagePickerController.InfoKey : Any]) -> Date? {
        guard let url = info[.imageURL] as? NSURL else { return nil }
        guard let imageSource = CGImageSourceCreateWithURL(url, nil) else { return nil }
        let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as Dictionary?
        print(imageProperties)
        let exifDict = imageProperties?[kCGImagePropertyExifDictionary]
        
        guard let dateTimeOriginal = exifDict?[kCGImagePropertyExifDateTimeOriginal] as? String else {
            return nil
        }
        
        let format = "yyyy-MM-dd HH:mm:ss"
        return makeExitDate(of: dateTimeOriginal, by: format)
    }
    
    func makeExitDate(of dateTimeOriginal: String, by format: String) -> Date? {
        let dateOfFirstSection = String(dateTimeOriginal.split(separator: " ").first ?? "")
        let dateOfSecondSection = String(dateTimeOriginal.split(separator: " ").last ?? "")
        var exitDate = dateOfFirstSection.replacingOccurrences(of: ":", with: "-")
        exitDate = exitDate + " " + dateOfSecondSection
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.date(from: exitDate)
        return Date()
    }
}

extension Date {
    func toString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        return dateFormatter.string(from: self)
    }
}

extension String {
  func rsaEncryption(publicKey: String) -> String {
    let publicKey = try! PublicKey(base64Encoded: publicKey)
    let clear = try! ClearMessage(string: self, using: .utf8)
    let encrypted = try! clear.encrypted(with: publicKey, padding: .PKCS1)
    return encrypted.base64String
  }
}
