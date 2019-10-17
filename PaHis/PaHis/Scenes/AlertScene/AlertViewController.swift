//
//  AlertViewController.swift
//  PaHis
//
//  Created by ulima on 6/16/19.
//  Copyright © 2019 Maple. All rights reserved.
//

import Firebase
import LocationPickerViewController
import UIKit

class AlertTableViewController: UITableViewController, UIImagePickerControllerDelegate , UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UITextViewDelegate {
    
    var desc: String!
    var codBuild: String!
    var direccion: String!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var descTextView: UITextView!
    @IBOutlet weak var cameraUIImage: UIImageView!
    @IBOutlet weak var createButton: UIButton!
    
    var photos = [UIImage]()
    let placeholder = "Ingrese una descripción del daño o modificación"
    var addressLocation: (latitude: Double, longitude: Double)?
    private var spinner = UIView()
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cameraUIImage.image = cameraUIImage.image?.withRenderingMode(.alwaysTemplate)
        cameraUIImage.tintColor = UIColor.lightGray
        self.createButton.backgroundColor = UIColor(rgb: 0xF5391C)
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = true
        }
        title = "Alerta"
        setupView()
    }
    
    func setupView() {
        cameraUIImage.image = cameraUIImage.image?.withRenderingMode(.alwaysTemplate)
        cameraUIImage.tintColor = UIColor.lightGray
        self.createButton.backgroundColor = UIColor(rgb: 0xF5391C)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(addressLabelPressed))
        addressLabel.addGestureRecognizer(tapGesture)
        addressLabel.isUserInteractionEnabled = true
        
        descTextView.text = placeholder
        descTextView.textColor = UIColor.lightGray
        descTextView.delegate = self
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func cameraButtonPressed(_ sender: UIButton) {
        //Insertar funcion para cambiar imagen aqui
        let alert = UIAlertController(title: "Aviso", message: "Elige desde donde deseas agregar una foto", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Abrir cámara", style: .default, handler: { (action) in
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
    
    @objc func addressLabelPressed(){
        let locationPicker = LocationPicker()
        locationPicker.pickCompletion = { (pickedLocationItem) in
            self.addressLabel.textColor = .black
            self.addressLabel.text = pickedLocationItem.name
            self.addressLocation = pickedLocationItem.coordinate
        }
        locationPicker.setColors(themeColor: UIColor(rgb: 0xF5391C), primaryTextColor: .black, secondaryTextColor: .black)
        locationPicker.searchBarPlaceholder = "Busca una dirección aquí"
        locationPicker.currentLocationText = "Ubicación actual"
        locationPicker.locationDeniedAlertTitle = "Acceso a tu ubicación denegada"
        locationPicker.locationDeniedAlertMessage = "Permite el acceso a tu ubicación para usar tu ubicación actual"
        locationPicker.locationDeniedGrantText = "Permitir"
        locationPicker.locationDeniedCancelText = "Cancelar"
        locationPicker.addBarButtons(doneButtonItem: UIBarButtonItem(title: "Seleccionar", style: .done, target: self, action: nil), cancelButtonItem: UIBarButtonItem(title: "Cancelar", style: .plain, target: self, action: nil), doneButtonOrientation: .right)
        present(UINavigationController(rootViewController: locationPicker), animated: true, completion: nil)
    }
    
    @IBAction func registerButtonPressed(_ sender: Any) {
        guard let currentUser = User.currentUser else {
            let alert = UIAlertController(title: "Aviso", message: "Su sessión ha expirado", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            return
        }
        guard !photos.isEmpty else {
            let alert = UIAlertController(title: "Aviso", message: "Capture por lo menos una imagen", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            return
        }
        guard let name = nameTextField.text, !name.isEmpty else {
            let alert = UIAlertController(title: "Aviso", message: "Ingrese un nombre válido", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            return
        }
        guard let addressName = addressLabel.text, !addressName.isEmpty, let addressCordinates = addressLocation  else {
            let alert = UIAlertController(title: "Aviso", message: "Ingrese una dirección válida", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            return
        }
        guard descTextView.text != "",descTextView.text != placeholder , let descripcion = descTextView.text else {
            let alert = UIAlertController(title: "Aviso", message: "Ingrese una descripción válida", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            return
        }
        
        
        spinner = UIViewController.displaySpinner(onView: self.view)
        
        var images = [[String:String]]()
        photos.forEach({
            let image = ["data":$0.jpegData(compressionQuality: 0.6)!.base64EncodedString(),"extension":"jpeg"]
            images.append(image)
        })
        
        NetworkManager.shared.sendIndependentAlert(token: currentUser.token, latitude: addressCordinates.latitude, longitude: addressCordinates.longitude, address: addressName, images: images, name: name, description: descripcion) { result in
            UIViewController.removeSpinner(spinner: self.spinner)
            switch result {
            case .failure(let error):
                let alert = UIAlertController(title: "Aviso", message: error.errorDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
                self.present(alert, animated: true)
            case .success(_):
                let alert = UIAlertController(title: "Aviso", message: "Alerta enviada satisfactoriamente", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: { _ in
                    self.clearData()
                    self.navigationController?.popViewController(animated: true)
                }))
                self.present(alert, animated: true)
            }
            
        }
        
//        let spinner = UIViewController.displaySpinner(onView: self.view)
        
//        let data = cameraUIImage.image!.jpegData(compressionQuality: 0.9)!
//        let alertaImageRef = Storage.storage().reference().child("alertaImages/\(UUID().uuidString).jpg")
//        _ = alertaImageRef.putData(data, metadata: nil, completion: { (metadata, error) in
//            guard error == nil else {
//                UIViewController.removeSpinner(spinner: spinner)
//                self.navigationItem.rightBarButtonItem?.isEnabled = true
//                print("Error al subir la imagen de perfil: ", error!.localizedDescription)
//                return
//            }
//            guard let metadata = metadata else {
//                UIViewController.removeSpinner(spinner: spinner)
//                self.navigationItem.rightBarButtonItem?.isEnabled = true
//                print("No hay metadata")
//                return
//            }
//            guard let user = Auth.auth().currentUser else {
//                UIViewController.removeSpinner(spinner: spinner)
//                self.navigationItem.rightBarButtonItem?.isEnabled = true
//                return
//            }
//            alertaImageRef.downloadURL(completion: { (url, error) in
//                guard error == nil else {
//                    UIViewController.removeSpinner(spinner: spinner)
//                    self.navigationItem.rightBarButtonItem?.isEnabled = true
//                    print("Error al obtener la url del profile")
//                    return
//                }
//                guard let downloadURL = url else {
//                    UIViewController.removeSpinner(spinner: spinner)
//                    return
//                }
//                let ref = Database.database().reference()
//                ref.child("alertas").child(user.uid).child(UUID().uuidString).setValue(["photo": downloadURL.absoluteString, "descripcion": descripcion, "codInmueble" : self.codBuild, "dirección" : self.direccion])
//                UIViewController.removeSpinner(spinner: spinner)
//                let alert = UIAlertController(title: "Aviso", message: "Registro enviado satisfactoriamente", preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (_) in
//                    _ = self.navigationController?.popViewController(animated: true)
//                }))
//                self.present(alert, animated: true)
//            })
//        })
        
    }
    
    func clearData() {
        nameTextField.text = ""
        addressLabel.text = "Dirección"
        addressLabel.textColor = .lightGray
        descTextView.text = ""
        photos.removeAll()
        collectionView.reloadData()
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
        photos.append(image.resizeImageWith(newSize: CGSize(width: 200, height: 200)))
        collectionView.reloadData()
        dismiss(animated:true, completion: nil)
    }
    
    // MARK:- Funciones del delegate del collectionView
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AlertCollectionViewCell.identifier, for: indexPath) as! AlertCollectionViewCell
        cell.row = indexPath.row
        cell.deletegate = self
        cell.photo = photos[indexPath.row]
        return cell
    }
    
    // MARK:- Funciones del delegate del textArea
    
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

extension AlertTableViewController: DeletePhotoDelegate {
    func deletePhotoAt(row: Int) {
        photos.remove(at: row)
        collectionView.reloadData()
    }
}

extension AlertTableViewController {
    
}
