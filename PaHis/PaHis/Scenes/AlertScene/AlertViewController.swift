//
//  AlertViewController.swift
//  PaHis
//
//  Created by ulima on 6/16/19.
//  Copyright © 2019 Maple. All rights reserved.
//

import Firebase
import UIKit

class AlertTableViewController: UITableViewController, UIImagePickerControllerDelegate , UINavigationControllerDelegate  {
    
    var desc: String!
    var codBuild: String!
    var direccion: String!
    
    @IBOutlet weak var descTextField: UITextField!
    @IBOutlet weak var cameraUIImage: UIImageView!
    @IBOutlet weak var createButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cameraUIImage.image = cameraUIImage.image?.withRenderingMode(.alwaysTemplate)
        cameraUIImage.tintColor = UIColor.lightGray
        self.createButton.backgroundColor = UIColor(rgb: 0xF5391C)
        title = desc
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func cameraButtonPressed(_ sender: Any) {
        //Insertar funcion para cambiar imagen aqui
        let alert = UIAlertController(title: "Aviso", message: "Elige desde donde deseas agregar una foto", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Abrir cámara", style: .default, handler: { (action) in
            self.openCamera()
        }))
        alert.addAction(UIAlertAction(title: "Abrir librería de fotos", style: .default, handler: { (action) in
            self.openPhotoLibrary()
        }))
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    @IBAction func registerButtonPressed(_ sender: Any) {
        guard descTextField.text != "", let descripcion = descTextField.text else {
            let alert = UIAlertController(title: "Aviso", message: "Ingrese una descripción válida", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            return
        }
        let spinner = UIViewController.displaySpinner(onView: self.view)
        let data = cameraUIImage.image!.jpegData(compressionQuality: 0.9)!
        let alertaImageRef = Storage.storage().reference().child("alertaImages/\(UUID().uuidString).jpg")
        _ = alertaImageRef.putData(data, metadata: nil, completion: { (metadata, error) in
            guard error == nil else {
                UIViewController.removeSpinner(spinner: spinner)
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                print("Error al subir la imagen de perfil: ", error!.localizedDescription)
                return
            }
            guard let metadata = metadata else {
                UIViewController.removeSpinner(spinner: spinner)
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                print("No hay metadata")
                return
            }
            guard let user = Auth.auth().currentUser else {
                UIViewController.removeSpinner(spinner: spinner)
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                return
            }
            alertaImageRef.downloadURL(completion: { (url, error) in
                guard error == nil else {
                    UIViewController.removeSpinner(spinner: spinner)
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                    print("Error al obtener la url del profile")
                    return
                }
                guard let downloadURL = url else {
                    UIViewController.removeSpinner(spinner: spinner)
                    return
                }
                let ref = Database.database().reference()
                ref.child("alertas").child(user.uid).child(UUID().uuidString).setValue(["photo": downloadURL.absoluteString, "descripcion": descripcion, "codInmueble" : self.codBuild, "dirección" : self.direccion])
                UIViewController.removeSpinner(spinner: spinner)
                let alert = UIAlertController(title: "Aviso", message: "Registro enviado satisfactoriamente", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (_) in
                    _ = self.navigationController?.popViewController(animated: true)
                }))
                self.present(alert, animated: true)
            })
        })
        
    }
    
    //Insertar Funciones extra aqui
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
        cameraUIImage.image = image.resizeImageWith(newSize: CGSize(width: 200, height: 200))
        dismiss(animated:true, completion: nil)
    }
}
