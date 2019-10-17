//
//  SwipeAlertTableViewController.swift
//  PaHis
//
//  Created by Leonardo Luna on 9/25/19.
//  Copyright © 2019 Maple. All rights reserved.
//

import UIKit

class SwipeAlertTableViewController: UITableViewController, UITextViewDelegate {
    
    @IBOutlet weak var sendAlertButon: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var photoButton: UIButton!
//    @IBOutlet weak var alertPhotoImageView: UIImage!
    
    var building: BuildingPahis!
    let placeholder = "Ingrese una descripción del daño o modificación"
    var hasPicture = false
    private var spinner = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sendAlertButon.backgroundColor = UIColor(rgb: 0xF5391C)
        textView.text = placeholder
        textView.textColor = UIColor.lightGray
        textView.delegate = self
        self.title = building.name
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = true
        }
//        self.photoButton.layer.cornerRadius = self.photoButton.frame.size.width / 2
//        self.photoButton.clipsToBounds = true
//        self.photoButton.imageView?.contentMode = .scaleAspectFill
    }
    
    
    @IBAction func sendAlertButton(_ sender: UIButton) {
        self.view.endEditing(true)
        guard let currentUser = User.currentUser else {
            let alert = UIAlertController(title: "Aviso", message: "Su sessión ha expirado", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            return
        }
        guard hasPicture == true, let alertImage = photoButton.image(for: .normal) else {
            let alert = UIAlertController(title: "Aviso", message: "Capture una imagen", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            return
        }
        guard let id = building.id else {
            let alert = UIAlertController(title: "Aviso", message: "No hay edificio seleccionado", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            return
        }
        guard nameTextField.text != "", let name = nameTextField.text  else {
            let alert = UIAlertController(title: "Aviso", message: "Ingrese un nombre para la denuncia", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            return
        }
        guard textView.text != "", textView.text != placeholder, let description = textView.text  else {
            let alert = UIAlertController(title: "Aviso", message: "Ingrese una descripción para la denuncia", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            return
        }
        spinner = UIViewController.displaySpinner(onView: self.view)
        let encodedImage = alertImage.jpegData(compressionQuality: 0.6)!.base64EncodedString()
        let images = [["data":encodedImage,"extension":"jpeg"]]
        NetworkManager.shared.sendAlert(token: currentUser.token, images: images, id: Int(id), name: name, description: description, address: building.address ?? "-") { result in
            switch result {
            case .failure(let error):
                UIViewController.removeSpinner(spinner: self.spinner)
                let alert = UIAlertController(title: "Aviso", message: "A ocurrido un error: \(error.errorDescription)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
                self.present(alert, animated: true)
            case .success(let success):
                UIViewController.removeSpinner(spinner: self.spinner)
                let alert = UIAlertController(title: "Aviso", message: "denuncia enviada satisfactoriamente", preferredStyle: .alert)
                 alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: { _ in
                    self.navigationController?.popViewController(animated: true)
                 }))
                self.present(alert, animated: true)
            }
        }
    }
    
    @IBAction func photoButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Tomar foto", style: .default, handler: { (action) in
            self.openCamera()
        }))
        alert.addAction(UIAlertAction(title: "Abrir librería de fotos", style: .default, handler: { (action) in
            self.openPhotoLibrary()
        }))
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Ingrese una descripción del daño o modificación"
            textView.textColor = UIColor.lightGray
        }
    }
    

}

// MARK:- Camera Methods
extension SwipeAlertTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self
            myPickerController.sourceType = .camera
            myPickerController.allowsEditing = false
            self.present(myPickerController, animated: true, completion: nil)
        }
    }
    func openPhotoLibrary() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
//        alertPhotoImageView.image = image
//        photoButton.setImage(image, for: .normal)
        self.photoButton.layer.cornerRadius = self.photoButton.frame.size.width / 2
        self.photoButton.clipsToBounds = true
        self.photoButton.imageView?.contentMode = .scaleAspectFill
        photoButton.setImage(image.resizeImageWith(newSize: CGSize(width: 200, height: 200)), for: .normal)
        self.hasPicture = true
        dismiss(animated:true, completion: nil)
    }
}
