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
    @IBOutlet weak var genderSegmentedControl: UISegmentedControl!
    @IBOutlet weak var typeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var profileImageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Crear Nuevo Usuario"
        let cancelBarButtonItem = UIBarButtonItem(image: UIImage(named: "CancelIcon"), style: .plain, target: self, action: #selector(cancelButtonTapped))
        self.navigationController?.navigationBar.tintColor  = #colorLiteral(red: 0.9411764706, green: 0.4352941176, blue: 0.1882352941, alpha: 1)
        self.navigationItem.rightBarButtonItem = cancelBarButtonItem
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2
        self.profileImageView.clipsToBounds = true
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
        
        let gender = genderSegmentedControl.selectedSegmentIndex == 0 ? "Hombre" : "Mujer"
        
        var userType = ""
        
        switch typeSegmentedControl.selectedSegmentIndex {
        case 0:
            userType = "Ciudadano"
        case 1:
            userType = "Académico"
        case 2:
            userType = "Profesional"
        case 3:
            userType = "Ad Hoc"
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
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            guard error == nil else {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                UIViewController.removeSpinner(spinner: spinner)
                let alert = UIAlertController(title: "Aviso", message: "Error al crear el usuario: \(error!.localizedDescription)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
                self.present(alert, animated: true)
                return
            }
            guard let user = Auth.auth().currentUser else {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                UIViewController.removeSpinner(spinner: spinner)
                return
            }
            let profileImageRef = Storage.storage().reference().child("profileImages/\(user.uid).jpg")
            _ = profileImageRef.putData(data, metadata: nil) { (metadata, error) in
                guard error == nil else {
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                    UIViewController.removeSpinner(spinner: spinner)
                    print("Error al subir la imagen de perfil: ", error!.localizedDescription)
                    return
                }
                guard let metadata = metadata else {
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                    UIViewController.removeSpinner(spinner: spinner)
                    print("No hay metadata")
                    return
                }
                let size = metadata.size
                print("Tamaño de la imagen: ", size)
                profileImageRef.downloadURL { (url, error) in
                    guard error == nil else {
                        self.navigationItem.rightBarButtonItem?.isEnabled = true
                        UIViewController.removeSpinner(spinner: spinner)
                        print("Error al obtener la url del profile")
                        return
                    }
                    guard let downloadURL = url else {
                        self.navigationItem.rightBarButtonItem?.isEnabled = true
                        UIViewController.removeSpinner(spinner: spinner)
                        return
                    }
                    let ref = Database.database().reference()
                    ref.child("users").child(user.uid).setValue(["correo": email, "nombre": name, "genero": gender, "userType" : userType , "profileImageURL": downloadURL.absoluteString])
                    
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                    UIViewController.removeSpinner(spinner: spinner)
                    let alert = UIAlertController(title: "Aviso", message: "Usuario creado satisfactoriamente.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: { _ in
                        do {
                            try Auth.auth().signOut()
                        } catch let signOutError as NSError {
                            print ("Error signing out: %@", signOutError)
                        }
                        self.dismiss(animated: true, completion: nil)
                    }))
                    self.present(alert, animated: true)
                }
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
