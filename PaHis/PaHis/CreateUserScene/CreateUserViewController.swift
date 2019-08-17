//
//  CreateUserViewController.swift
//  PaHis
//
//  Created by ulima on 6/15/19.
//  Copyright © 2019 Maple. All rights reserved.
//

import UIKit
import Firebase

class CreateUserTableViewController: UITableViewController , UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var typeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var changePhotoLabel: UIButton!
    @IBOutlet weak var createUserButton: UIButton!
    @IBOutlet weak var roleSegmentColor: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    func setupView() {
        self.title = "Crear Nuevo Usuario"
        let cancelBarButtonItem = UIBarButtonItem(image: UIImage(named: "CancelIcon"), style: .plain, target: self, action: #selector(cancelButtonTapped))
        self.navigationController?.navigationBar.tintColor  = UIColor(rgb: 0xF5391C)
        self.navigationItem.rightBarButtonItem = cancelBarButtonItem
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2
        self.profileImageView.clipsToBounds = true
        self.changePhotoLabel.tintColor = UIColor(rgb: 0xF5391C)
        self.createUserButton.backgroundColor = UIColor(rgb: 0xF5391C)
        self.roleSegmentColor.tintColor = UIColor(rgb: 0xF5391C)
    }
    
    @objc func cancelButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func createNewUserButtonTapped(_ sender: UIButton) {
        view.endEditing(true)
        //Insertar funcion para crear cuenta aqui
        guard let email = emailTextField.text, email.contains("@"), email.split(separator: "@").count == 2 else {
            let alert = UIAlertController(title: "Aviso", message: "Ingresa un correo válido.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            return
        }
        guard let name = nameTextField.text, name.count > 6 else {
            let alert = UIAlertController(title: "Aviso", message: "Ingresa un nombre mayor a 6 letras.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            return
        }
        
        var userType = ""
        
        switch typeSegmentedControl.selectedSegmentIndex {
        case 0:
            userType = "Normal"
        case 1:
            userType = "Voluntario"
        default:
            userType = "Other"
        }
        
        guard let password = passwordTextField.text, password.count > 6 else {
            let alert = UIAlertController(title: "Aviso", message: "Ingresa una contraseña mayor a 6 caracteres.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            return
        }
        
        let data = profileImageView.image!.jpegData(compressionQuality: 0.9)!
        
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        let spinner = UIViewController.displaySpinner(onView: self.view)
        
        NetworkManager.shared.createUser(name: name, email: email, userType: userType, profilePicURL: "urlfotoperfildummy", password: password) { result in
            switch result {
            case .failure(let error):
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                UIViewController.removeSpinner(spinner: spinner)
                let alert = UIAlertController(title: "Aviso", message: error.errorDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(alert, animated: true)
            case .success(let message):
                let alert = UIAlertController(title: "Aviso", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: { _ in
                    //Nos logueamos automáticamente
                    NetworkManager.shared.login(email: email, password: password) { result in
                        switch result {
                        case .failure(let error):
                            self.navigationItem.rightBarButtonItem?.isEnabled = true
                            UIViewController.removeSpinner(spinner: spinner)
                            let alert = UIAlertController(title: "Aviso", message: error.errorDescription, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                            self.present(alert, animated: true)
                        case .success(let token):
                            self.navigationItem.rightBarButtonItem?.isEnabled = true
                            UIViewController.removeSpinner(spinner: spinner)
                            UserDefaults.standard.set(token, forKey: "token")
                            print("Usuario logueado exitosamente")
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                }))
                self.present(alert, animated: true)
            }
        }
    }
    
    @IBAction func changeProfileImage(_ sender: UIButton) {
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
        profileImageView.image = image.resizeImageWith(newSize: CGSize(width: 200, height: 200))
        dismiss(animated:true, completion: nil)
    }
}
