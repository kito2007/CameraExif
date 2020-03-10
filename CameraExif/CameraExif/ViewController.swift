//
//  ViewController.swift
//  CameraExif
//
//  Created by Eunjin on 05/03/2020.
//  Copyright © 2020 Eunjin. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController {

    @IBOutlet weak var exifImageView: UIImageView!
    @IBOutlet weak var exifImageDataLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
}

extension ViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else { return }
        exifImageView.image = image
        if let date = self.getCreateDate(by: info) {
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
