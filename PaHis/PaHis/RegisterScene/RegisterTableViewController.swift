//
//  RegisterTableViewController.swift
//  PaHis
//
//  Created by Leo on 6/15/19.
//  Copyright © 2019 Maple. All rights reserved.
//

import UIKit

class RegisterTableViewController: UITableViewController, UIImagePickerControllerDelegate , UINavigationControllerDelegate  {

    @IBOutlet weak var distritoUILabel: UITextField!
    @IBOutlet weak var categoryUILabel: UITextField!
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
        createToolbar2()
        cameraUIImage.image = cameraUIImage.image?.withRenderingMode(.alwaysTemplate)
        cameraUIImage.tintColor = UIColor.lightGray
        self.createButton.backgroundColor = UIColor.black
    }
    
    func createDayPicker() {
        
        let dayPicker = UIPickerView()
        dayPicker.delegate = self
        dayPicker.restorationIdentifier = "category"
        
        categoryUILabel.inputView = dayPicker
    }
    
    func createDistritoPicker() {
        
        let distritoPicker = UIPickerView()
        distritoPicker.delegate = self
        distritoPicker.restorationIdentifier = "distrito"

        
        distritoUILabel.inputView = distritoPicker
    }
    
    func createToolbar() {
        
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.dismissKeyboard))
        
        toolBar.setItems([doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        categoryUILabel.inputAccessoryView = toolBar
    }
    
    func createToolbar2() {
        
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.dismissKeyboard))
        
        toolBar.setItems([doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        distritoUILabel.inputAccessoryView = toolBar
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
            selectedDistrito = distrito[row]
            distritoUILabel.text = selectedDistrito
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
