//
//  RegisterTableViewController.swift
//  PaHis
//
//  Created by Leo on 6/15/19.
//  Copyright © 2019 Maple. All rights reserved.
//
import Firebase
import UIKit

class RegisterTableViewController: UITableViewController, UIImagePickerControllerDelegate , UINavigationControllerDelegate  {

    @IBOutlet weak var descripcionTextField: UITextField!
//    @IBOutlet weak var distritoUILabel: UITextField!
    @IBOutlet weak var categoryUILabel: UITextField!
    @IBOutlet weak var direccionTextField: UITextField!
    @IBOutlet weak var observacionTextField: UITextField!
    @IBOutlet weak var cameraUIImage: UIImageView!
    @IBOutlet weak var createButton: UIButton!
    
    let categories = ["Paisaje Cultural Arqueológico e Histórico",
                "Zona Monumental",
                "Ambiente Urbano Monumental",
                "Monumento",
                "Zona Histórico Monumental",
                "Valor Urbanistico De Entorno",
                "Inmueble Identificado para su Declaración",
                "Inmueble De Valor Monumental",
                "Zona Paisajística de Valor Monumental",
                "Ambiente Monumental",
                "Sitio Histórico de batalla"]
    
    let distrito = ["Ancon","Ate","Barranco","Breña","Carabayllo","Chaclacayo","Chorrillos","Cieneguilla","Comas","El Agustino","Independencia","Jesus Maria","La Molina","La Victoria","Lima","Lince","Los Olivos","Lurigancho","Lurin","Magdalena Del Mar","Miraflores","Pachacamac","Pucusana","Pueblo Libre","Puente Piedra","Punta Hermosa","Punta Negra","Rimac","San Bartolo","San Borja","San Isidro","San Juan De Lurigancho","San Juan De Miraflores","San Luis","San Martin De Porres","San Miguel","Santa Anita","Santa Maria Del Mar","Santa Rosa","Santiago De Surco","Surquillo","Villa El Salvador","Villa Maria Del Triunfo"]
    var selectedCategory: String?
    var selectedDistrito: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createDayPicker()
        createToolbar()
        createDistritoPicker()
//        createToolbar2()
        cameraUIImage.image = cameraUIImage.image?.withRenderingMode(.alwaysTemplate)
        cameraUIImage.tintColor = UIColor.lightGray
        self.createButton.backgroundColor = UIColor.black
    }
    
    func createDayPicker() {
        
        let dayPicker = UIPickerView()
        dayPicker.delegate = self
        dayPicker.restorationIdentifier = "category"
        dayPicker.backgroundColor = .white
        
        categoryUILabel.inputView = dayPicker
    }
    
    func createDistritoPicker() {
        
        let distritoPicker = UIPickerView()
        distritoPicker.delegate = self
        distritoPicker.restorationIdentifier = "distrito"
        distritoPicker.backgroundColor = .white
        
//        distritoUILabel.inputView = distritoPicker
    }
    
    func createToolbar() {
        
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.dismissKeyboard))
        
        toolBar.setItems([doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        categoryUILabel.inputAccessoryView = toolBar
    }
    
//    func createToolbar2() {
//
//        let toolBar = UIToolbar()
//        toolBar.sizeToFit()
//
//        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.dismissKeyboard))
//
//        toolBar.setItems([doneButton], animated: false)
//        toolBar.isUserInteractionEnabled = true
//
//        distritoUILabel.inputAccessoryView = toolBar
//    }
    
    
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
        guard descripcionTextField.text != "", let descripcion = descripcionTextField.text else {
            let alert = UIAlertController(title: "Aviso", message: "Ingrese una descripción válida", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            return
        }
//        guard distritoUILabel.text != "", let distrito = distritoUILabel.text  else {
//            let alert = UIAlertController(title: "Aviso", message: "Ingrese un distrito válida", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
//            self.present(alert, animated: true)
//            return
//        }
        guard categoryUILabel.text != "", let categoria = categoryUILabel.text  else {
            let alert = UIAlertController(title: "Aviso", message: "Ingrese una categoria válida", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            return
        }
        guard direccionTextField.text != "", let direccion = direccionTextField.text  else {
            let alert = UIAlertController(title: "Aviso", message: "Ingrese una dirección válida", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            return
        }
        guard observacionTextField.text != "", let observacion = observacionTextField.text  else {
            let alert = UIAlertController(title: "Aviso", message: "Ingrese una observación válida", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            return
        }
        let spinner = UIViewController.displaySpinner(onView: self.view)
        let data = cameraUIImage.image!.jpegData(compressionQuality: 0.9)!
        let registroImageRef = Storage.storage().reference().child("registroImages/\(UUID().uuidString).jpg")
        _ = registroImageRef.putData(data, metadata: nil, completion: { (metadata, error) in
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
            registroImageRef.downloadURL(completion: { (url, error) in
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
                ref.child("registros").child(user.uid).child(UUID().uuidString).setValue(["photo": downloadURL.absoluteString, "descripcion": descripcion, "distrito": "Breña", "categoria" : categoria , "direccion": direccion, "observaciones" : observacion, "estado" : "pendiente"])
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
}

extension RegisterTableViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.restorationIdentifier == "category" {
            return categories.count
        } else {
            return distrito.count
        }
    }
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.restorationIdentifier == "category" {
            return categories[row]
        } else {
            return distrito[row]
        }
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.restorationIdentifier == "category" {
            selectedCategory = categories[row]
            categoryUILabel.text = selectedCategory
        } else {
//            selectedDistrito = distrito[row]
//            distritoUILabel.text = selectedDistrito
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        var label: UILabel
        
        if let view = view as? UILabel {
            label = view
        } else {
            label = UILabel()
        }
        label.textAlignment = .center
        label.font = UIFont(name: "system", size: 8)
        
        if pickerView.restorationIdentifier == "category" {
            label.text = categories[row]
        } else {
            label.text = distrito[row]
        }
        
        
        return label
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        cameraUIImage.image = image.resizeImageWith(newSize: CGSize(width: 200, height: 200))
        dismiss(animated:true, completion: nil)
    }
}
