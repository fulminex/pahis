//
//  RegisterTableViewController.swift
//  PaHis
//
//  Created by Leo on 6/15/19.
//  Copyright © 2019 Maple. All rights reserved.
//

import Firebase
import LocationPickerViewController
import MobileCoreServices
import UIKit

class RegisterTableViewController: UITableViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate , UINavigationControllerDelegate, DeletePhotoDelegate, UITextViewDelegate {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descripcionTextField: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var documentsTextView: UITextView!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var cameraUIImage: UIImageView!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var reasonTextField: UITextField!
    @IBOutlet weak var termsImageView: UIImageView!
    
    var isTermsAcepted = false
    
    let distrito = ["Ancon","Ate","Barranco","Breña","Carabayllo","Chaclacayo","Chorrillos","Cieneguilla","Comas","El Agustino","Independencia","Jesus Maria","La Molina","La Victoria","Lima","Lince","Los Olivos","Lurigancho","Lurin","Magdalena Del Mar","Miraflores","Pachacamac","Pucusana","Pueblo Libre","Puente Piedra","Punta Hermosa","Punta Negra","Rimac","San Bartolo","San Borja","San Isidro","San Juan De Lurigancho","San Juan De Miraflores","San Luis","San Martin De Porres","San Miguel","Santa Anita","Santa Maria Del Mar","Santa Rosa","Santiago De Surco","Surquillo","Villa El Salvador","Villa Maria Del Triunfo"]
    var selectedCategory: String?
    var selectedDistrito: String?
    var addressLocation: (latitude: Double, longitude: Double)?
    
    var photos = [UIImage]()
    var documentsBase64EncondedString = [[String:String]]()
    
    var building: BuildingPahis!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = building.name ?? "Este patrimonio no tiene nombre"
        self.navigationController?.navigationBar.tintColor  = UIColor(rgb: 0xF5391C)
        
        let tapDocumentsGesture = UITapGestureRecognizer(target: self, action: #selector(attachDocument))
        documentsTextView.addGestureRecognizer(tapDocumentsGesture)
        
        let tapTerms = UITapGestureRecognizer(target: self, action: #selector(termsTapped))
        termsImageView.addGestureRecognizer(tapTerms)
        termsImageView.isUserInteractionEnabled = true
        
        cameraUIImage.image = cameraUIImage.image?.withRenderingMode(.alwaysTemplate)
        cameraUIImage.tintColor = UIColor.lightGray
        self.createButton.backgroundColor = UIColor.black
        setupfields()
    }
    
    func setupfields() {
        nameTextField.text = building.name ?? ""
        descripcionTextField.text = building.buildingDescription ?? ""
        addressTextField.text = building.address ?? ""
//        addressLabel.text = building.address ?? "Dirección"
    }
    
    @objc func termsTapped() {
        isTermsAcepted.toggle()
        termsImageView.image = isTermsAcepted ? UIImage(named: "checked") : UIImage(named: "nochecked")
    }
    
    @objc func cancelButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func attachDocument() {
        let types = [String(kUTTypePDF), "org.openxmlformats.wordprocessingml.document"]
        let importMenu = UIDocumentPickerViewController(documentTypes: types, in: .import)
        
        if #available(iOS 11.0, *) {
            importMenu.allowsMultipleSelection = true
        }
        
        importMenu.delegate = self
        importMenu.modalPresentationStyle = .formSheet
        
        present(importMenu, animated: true)
    }

    @IBAction func cameraButtonPressed(_ sender: UIButton) {
        let maxPhotos = 5
        if photos.count < maxPhotos {
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
        } else {
            let alert = UIAlertController(title: "Aviso", message: "El numero máximo de fotos es de \(maxPhotos)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil ))
            self.present(alert, animated: true)
        }
    }
    
    @IBAction func registerButtonPressed(_ sender: Any) {
        guard let currentUser = User.currentUser else {
            let alert = UIAlertController(title: "Aviso", message: "Su sessión ha expirado", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            return
        }
        guard reasonTextField.text != "", let reason = reasonTextField.text else {
            let alert = UIAlertController(title: "Aviso", message: "Ingrese una razón válida", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            return
        }
        guard let id = building.id else {
            let alert = UIAlertController(title: "Aviso", message: "Inmueble no disponible para edición", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            return
        }
        
        guard let name = nameTextField.text else {
            let alert = UIAlertController(title: "Aviso", message: "Ingrese un nombre válido", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            return
        }
        guard let descripcion = descripcionTextField.text else {
            let alert = UIAlertController(title: "Aviso", message: "Ingrese una descripción válida", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            return
        }
        guard let addrress = addressTextField.text else {
            let alert = UIAlertController(title: "Aviso", message: "Ingrese una dirección válida", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            return
        }
        guard isTermsAcepted else {
            let alert = UIAlertController(title: "Aviso", message: "Acepte el uso de su información para continuar", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            return
        }
        
        let spinner = UIViewController.displaySpinner(onView: self.view)
        
        var images = [[String:String]]()
        photos.forEach({
            let image = ["data":$0.jpegData(compressionQuality: 0.6)!.base64EncodedString(),"extension":"jpeg"]
            images.append(image)
        })
        
        NetworkManager.shared.createChangeRequest(token: currentUser.token, name: name, address: addrress, description: descripcion, reason: reason, id: Int(id), images: images, documents: documentsBase64EncondedString) { result in
            switch result {
            case .failure(let error):
                UIViewController.removeSpinner(spinner: spinner)
                let alert = UIAlertController(title: "Aviso", message: error.errorDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
                self.present(alert, animated: true)
            case .success(let message):
                UIViewController.removeSpinner(spinner: spinner)
                let alert = UIAlertController(title: "Aviso", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: { _ in
                   self.navigationController?.popViewController(animated: true)
                }))
                self.present(alert, animated: true)
            }
        }
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RegisterCollectionViewCell.identifier, for: indexPath) as! RegisterCollectionViewCell
        cell.photoImageView.image = photos[indexPath.row]
        cell.row = indexPath.row
        cell.delegate = self
        return cell
    }
    
    func deletePhotoAt(row: Int) {
        let alert = UIAlertController(title: "Aviso", message: "¿Esta seguro de que desea borrar esta imagen?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Sí", style: .destructive, handler: { (_) in
            self.photos.remove(at: row)
            self.collectionView.reloadData()
        }))
        self.present(alert, animated: true)
    }
    
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
            photos.append(image.resizeImageWith(newSize: CGSize(width: 200, height: 200)))
            collectionView.reloadData()
    //        cameraUIImage.image = image.resizeImageWith(newSize: CGSize(width: 200, height: 200))
            dismiss(animated:true, completion: nil)
        }
}


extension RegisterTableViewController: UIDocumentPickerDelegate {
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        print(urls)
        let maxDoc = 2
        guard urls.count <= maxDoc else {
            let alert = UIAlertController(title: "Aviso", message: "El numero máximo de documentos es de \(maxDoc)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil ))
            self.present(alert, animated: true)
            return
        }
        var documentsName = ""
        var documentsBase64 = [[String:String]]()
        var isFirst = true
        urls.forEach({
            guard let name = $0.absoluteString.split(separator: "/").last else {
                return
            }
            if isFirst {
                documentsName = String(name)
                isFirst = false
            } else {
                documentsName = documentsName + "\n" + String(name)
            }
            
            let coordinator = NSFileCoordinator(filePresenter: nil)
            let error = NSErrorPointer(nilLiteral: ())
            coordinator.coordinate(readingItemAt: $0, options: .forUploading, error: error) { (newUrl) in
                guard let data = NSData(contentsOf: newUrl) else { return }
                let document = ["data":data.base64EncodedString(),"extension":"pdf"]
                documentsBase64.append(document)
            }
        })
        self.documentsBase64EncondedString = documentsBase64
        documentsTextView.text = documentsName
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("documentPicker was cancelled")
//        dismiss(animated: true, completion: nil)
    }
}
