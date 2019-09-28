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
    //    @IBOutlet weak var distritoUILabel: UITextField!
    @IBOutlet weak var documentsTextView: UITextView!
    @IBOutlet weak var addressTextField: UITextField!
    //    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var observationsTextView: UITextView!
//    @IBOutlet weak var categoryUILabel: UITextField!
    @IBOutlet weak var cameraUIImage: UIImageView!
    @IBOutlet weak var createButton: UIButton!
    
//    var categories: [CategoryPahis]!
//    var categoriesName: [String]!
    
    let distrito = ["Ancon","Ate","Barranco","Breña","Carabayllo","Chaclacayo","Chorrillos","Cieneguilla","Comas","El Agustino","Independencia","Jesus Maria","La Molina","La Victoria","Lima","Lince","Los Olivos","Lurigancho","Lurin","Magdalena Del Mar","Miraflores","Pachacamac","Pucusana","Pueblo Libre","Puente Piedra","Punta Hermosa","Punta Negra","Rimac","San Bartolo","San Borja","San Isidro","San Juan De Lurigancho","San Juan De Miraflores","San Luis","San Martin De Porres","San Miguel","Santa Anita","Santa Maria Del Mar","Santa Rosa","Santiago De Surco","Surquillo","Villa El Salvador","Villa Maria Del Triunfo"]
    var selectedCategory: String?
    var selectedDistrito: String?
    var addressLocation: (latitude: Double, longitude: Double)?
    
    var photos = [UIImage]()
    var documentsBase64EncondedString = [[String:String]]()
    
    var building: BuildingPahis!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        createDayPicker()
//        createToolbar()
//        createDistritoPicker()
//        createToolbar2()
        self.title = building.name ?? "Este patrimonio no tiene nombre"
//        let cancelBarButtonItem = UIBarButtonItem(image: UIImage(named: "CancelIcon"), style: .plain, target: self, action: #selector(cancelButtonTapped))
        self.navigationController?.navigationBar.tintColor  = UIColor(rgb: 0xF5391C)
//        self.navigationItem.rightBarButtonItem = cancelBarButtonItem
        
//        selectedCategory = categoriesName.first!
        
        observationsTextView.text = "\nObservaciones: 200 caracteres max."
        observationsTextView.textColor = .lightGray
        observationsTextView.delegate = self
        
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(addressLabelPressed))
//        addressLabel.addGestureRecognizer(tapGesture)
        
        let tapDocumentsGesture = UITapGestureRecognizer(target: self, action: #selector(attachDocument))
        documentsTextView.addGestureRecognizer(tapDocumentsGesture)
        
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

    
//    @objc func addressLabelPressed(){
//        let locationPicker = LocationPicker()
//        locationPicker.pickCompletion = { (pickedLocationItem) in
//            self.addressLabel.textColor = .black
//            self.addressLabel.text = pickedLocationItem.name
//            self.addressLocation = pickedLocationItem.coordinate
//        }
//        locationPicker.setColors(themeColor: UIColor(rgb: 0xF5391C), primaryTextColor: .black, secondaryTextColor: .black)
//        locationPicker.searchBarPlaceholder = "Busca una dirección aquí"
//        locationPicker.currentLocationText = "Ubicación actual"
//        locationPicker.locationDeniedAlertTitle = "Acceso a tu ubicación denegada"
//        locationPicker.locationDeniedAlertMessage = "Permite el acceso a tu ubicación para usar tu ubicación actual"
//        locationPicker.locationDeniedGrantText = "Permitir"
//        locationPicker.locationDeniedCancelText = "Cancelar"
//        locationPicker.addBarButtons(doneButtonItem: UIBarButtonItem(title: "Seleccionar", style: .done, target: self, action: nil), cancelButtonItem: UIBarButtonItem(title: "Cancelar", style: .plain, target: self, action: nil), doneButtonOrientation: .right)
//        present(UINavigationController(rootViewController: locationPicker), animated: true, completion: nil)
//    }
    
//    func createDayPicker() {
//
//        let dayPicker = UIPickerView()
//        dayPicker.delegate = self
//        dayPicker.restorationIdentifier = "category"
//        dayPicker.backgroundColor = .white
//
//        categoryUILabel.inputView = dayPicker
//    }
//
//    func createDistritoPicker() {
//
//        let distritoPicker = UIPickerView()
//        distritoPicker.delegate = self
//        distritoPicker.restorationIdentifier = "distrito"
//        distritoPicker.backgroundColor = .white
        
//        distritoUILabel.inputView = distritoPicker
//    }
    
//    func createToolbar() {
//
//        let toolBar = UIToolbar()
//        toolBar.sizeToFit()
//
//        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(dismissKeyboard) )
//
//        toolBar.setItems([doneButton], animated: false)
//        toolBar.isUserInteractionEnabled = true
//
//        categoryUILabel.inputAccessoryView = toolBar
//    }
    
//    @objc func dismissKeyboard() {
//        categoryUILabel.text = selectedCategory
//        view.endEditing(true)
//    }

    @IBAction func cameraButtonPressed(_ sender: Any) {
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
            self.present(alert, animated: true)
        } else {
            let alert = UIAlertController(title: "Aviso", message: "El numero máximo de fotos es de \(maxPhotos)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil ))
            self.present(alert, animated: true)
        }
    }
    
    @IBAction func registerButtonPressed(_ sender: Any) {
        guard nameTextField.text != "", let name = nameTextField.text else {
            let alert = UIAlertController(title: "Aviso", message: "Ingrese un nombre válido", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            return
        }
        guard descripcionTextField.text != "", let descripcion = descripcionTextField.text else {
            let alert = UIAlertController(title: "Aviso", message: "Ingrese una descripción válida", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            return
        }
//        guard categoryUILabel.text != "", let categoria = categoryUILabel.text, let categoryID = categories.filter({ $0.name == categoria }).first?.id  else {
//            let alert = UIAlertController(title: "Aviso", message: "Ingrese una categoria válida", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
//            self.present(alert, animated: true)
//            return
//        }
//        guard let direccion = addressLabel.text, addressLabel.text != "Dirección", let coordinate = addressLocation  else {
//            let alert = UIAlertController(title: "Aviso", message: "Ingrese una dirección válida", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
//            self.present(alert, animated: true)
//            return
//        }
        guard observationsTextView.text != "", let observacion = observationsTextView.text  else {
            let alert = UIAlertController(title: "Aviso", message: "Ingrese una observación válida", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            return
        }
        
        guard let currentUser = User.currentUser else {
            let alert = UIAlertController(title: "Aviso", message: "Su sessión ha expirado", preferredStyle: .alert)
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
        
//        NetworkManager.shared.createBuilding(token: currentUser.token, name: name, coordinate: coordinate, address: direccion, description: descripcion, category: Int(categoryID), images: images, documents: documentsBase64EncondedString) { result in
//            switch result {
//            case .failure(let error):
//                UIViewController.removeSpinner(spinner: spinner)
//                let alert = UIAlertController(title: "Aviso", message: error.errorDescription, preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
//                self.present(alert, animated: true)
//            case .success(let message):
//                UIViewController.removeSpinner(spinner: spinner)
//                let alert = UIAlertController(title: "Aviso", message: message, preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
//                self.present(alert, animated: true)
//            }
//        }
        
        //TODO: Terminar esto
//        let alert = UIAlertController(title: "Aviso", message: "Registro enviado satisfactoriamente", preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (_) in
//            _ = self.navigationController?.popViewController(animated: true)
//        }))
//        self.present(alert, animated: true)
        
//        let spinner = UIViewController.displaySpinner(onView: self.view)
//        let data = cameraUIImage.image!.jpegData(compressionQuality: 0.9)!
//        let registroImageRef = Storage.storage().reference().child("registroImages/\(UUID().uuidString).jpg")
//        _ = registroImageRef.putData(data, metadata: nil, completion: { (metadata, error) in
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
//            registroImageRef.downloadURL(completion: { (url, error) in
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
//                ref.child("registros").child(user.uid).child(UUID().uuidString).setValue(["photo": downloadURL.absoluteString, "descripcion": descripcion, "distrito": "Breña", "categoria" : categoria , "direccion": direccion, "observaciones" : observacion, "estado" : "pendiente"])
//                UIViewController.removeSpinner(spinner: spinner)
//                let alert = UIAlertController(title: "Aviso", message: "Registro enviado satisfactoriamente", preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (_) in
//                    _ = self.navigationController?.popViewController(animated: true)
//                }))
//                self.present(alert, animated: true)
//            })
//        })
        
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
    
    // MARK:- ObservationsTextView Delegate Functions
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if observationsTextView.textColor == UIColor.lightGray {
            observationsTextView.text = nil
            observationsTextView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if observationsTextView.text.isEmpty {
            observationsTextView.text = "\nObservaciones: 200 caracteres max."
            observationsTextView.textColor = UIColor.lightGray
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (observationsTextView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        return numberOfChars <= 200
    }
    
}

//extension RegisterTableViewController: UIPickerViewDelegate, UIPickerViewDataSource {
//
//    func numberOfComponents(in pickerView: UIPickerView) -> Int {
//        return 1
//    }
//
//
//    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        if pickerView.restorationIdentifier == "category" {
//            return categoriesName.count
//        } else {
//            return distrito.count
//        }
//    }
//
//
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        if pickerView.restorationIdentifier == "category" {
//            return categoriesName[row]
//        } else {
//            return distrito[row]
//        }
//    }
//
//
//    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        if pickerView.restorationIdentifier == "category" {
//            selectedCategory = categoriesName[row]
//            categoryUILabel.text = selectedCategory
//        } else {
////            selectedDistrito = distrito[row]
////            distritoUILabel.text = selectedDistrito
//        }
//    }
//
//    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
//
//        var label: UILabel
//
//        if let view = view as? UILabel {
//            label = view
//        } else {
//            label = UILabel()
//        }
//        label.textAlignment = .center
//        label.font = UIFont(name: "system", size: 8)
//
//        if pickerView.restorationIdentifier == "category" {
//            label.text = categoriesName[row]
//        } else {
//            label.text = distrito[row]
//        }
//
//
//        return label
//    }
//
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
//        photos.append(image.resizeImageWith(newSize: CGSize(width: 200, height: 200)))
//        collectionView.reloadData()
////        cameraUIImage.image = image.resizeImageWith(newSize: CGSize(width: 200, height: 200))
//        dismiss(animated:true, completion: nil)
//    }
//}

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
