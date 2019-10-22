//
//  UsserInfoTableViewController.swift
//  PaHis
//
//  Created by Leonardo Luna on 9/26/19.
//  Copyright © 2019 Maple. All rights reserved.
//

import UIKit

class UsserInfoTableViewController: UITableViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var photoImageView: UIImageView!
    
    var spinner = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fillFields()
        self.tableView.tableFooterView = UIView()
        nameTextField.autocapitalizationType = .words
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    func fillFields() {
        guard let currentUser = User.currentUser else {
            let alert = UIAlertController(title: "Aviso", message: "Su sessión ha expirado", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            return
        }
        nameTextField.text = currentUser.name
        if let url = currentUser.profilePicUrl {
            photoImageView.kf.setImage(with: url)
        } else {
            photoImageView.image = UIImage(named: "UserNameIcon")
        }
        photoImageView.layer.cornerRadius = self.photoImageView.frame.size.width / 2
        photoImageView.contentMode = .scaleAspectFill
        photoImageView.kf.indicatorType = .activity
        photoImageView.clipsToBounds = true
    }

    @IBAction func imageButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Tomar foto", style: .default, handler: { (action) in
            self.openCamera()
        }))
        alert.addAction(UIAlertAction(title: "Abrir librería de fotos", style: .default, handler: { (action) in
            self.openPhotoLibrary()
        }))
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        if let popoverPresentationController = alert.popoverPresentationController {
            popoverPresentationController.sourceView = self.view
            popoverPresentationController.sourceRect = sender.bounds
        }
        self.present(alert, animated: true)
    }

    @IBAction func updateUserInfoButtonPressed(_ sender: UIButton) {
        guard let currentUser = User.currentUser else {
            let alert = UIAlertController(title: "Aviso", message: "Su sessión ha expirado", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            return
        }
        spinner = UIViewController.displaySpinner(onView: self.view)
        guard let name = nameTextField.text, name.count != 0 else {
            let alert = UIAlertController(title: "Aviso", message: "Ingresa tu nombre.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
            UIViewController.removeSpinner(spinner: spinner)
            self.present(alert, animated: true)
            return
        }
        var encodedImage: String = ""
        guard let image = photoImageView.image else {
            let alert = UIAlertController(title: "Aviso", message: "Ingresa tu imagen de perfil.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
            UIViewController.removeSpinner(spinner: spinner)
            self.present(alert, animated: true)
            return
        }
        encodedImage = image.jpegData(compressionQuality: 0.6)!.base64EncodedString()
        
        let images = [["data":encodedImage,"extension":"jpeg"]]
        
        NetworkManager.shared.updateUserInfo(uid: currentUser.uid, token: currentUser.token, images: images, name: name) { result in
            switch result {
            case .failure(let error):
                UIViewController.removeSpinner(spinner: self.spinner)
                let alert = UIAlertController(title: "Aviso", message: error.errorDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
                self.present(alert, animated: true)
            case .success(let succeess):
                UIViewController.removeSpinner(spinner: self.spinner)
                let alert = UIAlertController(title: "Aviso", message: succeess, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: { _ in
                   self.navigationController?.popViewController(animated: true)
                }))
                self.present(alert, animated: true)
            }
        }
    }
}

// MARK:- Camera Methods
extension UsserInfoTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
        photoImageView.image = image.resizeImageWith(newSize: CGSize(width: 200, height: 200))
        dismiss(animated:true, completion: nil)
    }
}
