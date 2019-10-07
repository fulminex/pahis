//
//  FiltersViewController.swift
//  PaHis
//
//  Created by Carolina Esquivel on 9/22/19.
//  Copyright © 2019 Maple. All rights reserved.
//

struct Filter {
    var categoryID: String?
    var codUbigeo: String?
}

protocol FilterPopUpDelegate {
    func getFilter(filter: Filter)
}

import UIKit

class FiltersViewController: UIViewController {
    
    @IBOutlet weak var categoryButton: UIButton!
    @IBOutlet weak var departmentButton: UIButton!
    @IBOutlet weak var provinciaButton: UIButton!
    @IBOutlet weak var distritoButton: UIButton!
    
    var isCategory = false
    var isDepartment = false
    var isProvincia = false
    var isDistrito = false
    
    var selectedCategory: CategoryPahis?
    var selectedDepartment: Ubigeo?
    var selectedProvincia: Ubigeo?
    var selectedDistrito: Ubigeo?
    
    var categories: [CategoryPahis]!
    var departments: [Ubigeo]?
    var provincias: [Ubigeo]?
    var distritos: [Ubigeo]?
    
    var delegate: FilterPopUpDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchDepartments()
    }
    
    @IBAction func applyButtonPressed(_ sender: UIButton) {
        var codUbigeo: String? = nil
        if selectedDepartment != nil {
            codUbigeo = String(String(selectedDepartment!.codUbigeo!).prefix(2))
            if selectedProvincia != nil {
                codUbigeo = String(String(selectedProvincia!.codUbigeo!).prefix(4))
                if selectedDistrito != nil {
                    codUbigeo = String(selectedDistrito!.codUbigeo!)
                }
            }
        }
        delegate.getFilter(filter: Filter(categoryID: selectedCategory != nil ? String(selectedCategory!.id!) : nil , codUbigeo: codUbigeo))
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func categoryButtonPressed(_ sender: UIButton) {
        isCategory = true
        openPicker(items: ["Todas"] + categories.map({ $0.name! }))
    }
    
    @IBAction func departmentButtonPressedç(_ sender: UIButton) {
        guard departments != nil else { return }
        isDepartment = true
        openPicker(items: ["Todos"] + departments!.map({ $0.nombre! }))
    }
    
    @IBAction func provinciaButtonPressed(_ sender: UIButton) {
        guard provincias != nil else {
            let alert = UIAlertController(title: "Aviso", message: "Selecciona primero un departamento", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        isProvincia = true
        openPicker(items: ["Todas"] + provincias!.map({ $0.nombre! }))
    }
    
    @IBAction func distritoButtonPressed(_ sender: UIButton) {
        guard distritos != nil else {
            let alert = UIAlertController(title: "Aviso", message: "Selecciona primero una provincia", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        isDistrito = true
        openPicker(items: ["Todos"] + distritos!.map({ $0.nombre! }))
    }
    
    func fetchDepartments() {
        let spinner = UIViewController.displaySpinner(onView: self.view)
        NetworkManager.shared.getDepartments { (result) in
            UIViewController.removeSpinner(spinner: spinner)
            switch result {
            case .failure(let error):
                print(error.errorDescription)
            case .success(let departments):
                self.departments = departments.sorted(by: { $0.nombre! < $1.nombre! })
            }
        }
    }
    
    func fetchProvincias() {
        let spinner = UIViewController.displaySpinner(onView: self.view)
        let id = String(selectedDepartment!.codUbigeo!).prefix(2)
        NetworkManager.shared.getProvincias(departmentID: String(id)) { (result) in
            UIViewController.removeSpinner(spinner: spinner)
            switch result {
            case .failure(let error):
                print(error.errorDescription)
            case .success(let provincias):
                self.provincias = provincias.sorted(by: { $0.nombre! < $1.nombre! })
            }
        }
    }
    
    func fetchDistritos() {
        let spinner = UIViewController.displaySpinner(onView: self.view)
        let id = String(selectedProvincia!.codUbigeo!).prefix(4)
        NetworkManager.shared.getDistritos(id: String(id)) { (result) in
            UIViewController.removeSpinner(spinner: spinner)
            switch result {
            case .failure(let error):
                print(error.errorDescription)
            case .success(let distritos):
                self.distritos = distritos.sorted(by: { $0.nombre! < $1.nombre! })
            }
        }
    }
    
    func openPicker(items: [String]) {
        let sb = UIStoryboard(name: "Picker", bundle: nil)
        let vc = sb.instantiateInitialViewController() as! PickerViewController
        vc.items = items
        vc.delegate = self
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overCurrentContext
        self.present(vc, animated: true)
    }
    
}

extension FiltersViewController: PopUpPickerViewDelegate {
    func getItemSelected(value: String) {
        if isCategory {
            isCategory = false
            categoryButton.setTitle(value, for: .normal)
            guard value != "Todas" else {
                selectedCategory = nil
                return
            }
            selectedCategory = categories?.filter({ $0.name == value }).first!
        }
        if isDepartment {
            isDepartment = false
            departmentButton.setTitle(value, for: .normal)
            guard value != "Todos" else {
                selectedDepartment = nil
                selectedProvincia = nil
                selectedDistrito = nil
                provinciaButton.setTitle("Todas", for: .normal)
                distritoButton.setTitle("Todos", for: .normal)
                return
            }
            selectedDepartment = departments?.filter({ $0.nombre == value }).first!
            selectedProvincia = nil
            selectedDistrito = nil
            provinciaButton.setTitle("Todas", for: .normal)
            distritoButton.setTitle("Todos", for: .normal)
            fetchProvincias()
        }
        if isProvincia {
            isProvincia = false
            provinciaButton.setTitle(value, for: .normal)
            guard value != "Todas" else {
                selectedProvincia = nil
                selectedDistrito = nil
                distritoButton.setTitle("Todos", for: .normal)
                return
            }
            selectedProvincia = provincias?.filter({ $0.nombre == value }).first!
            selectedDistrito = nil
            distritoButton.setTitle("Todos", for: .normal)
            fetchDistritos()
        }
        if isDistrito {
            isDistrito = false
            distritoButton.setTitle(value, for: .normal)
            guard value != "Todos" else {
                selectedDistrito = nil
                return
            }
            selectedDistrito = distritos?.filter({ $0.nombre == value }).first!
        }
    }
    
    func cancelButtonPressed(){
        isCategory = false
        isDepartment = false
        isProvincia = false
        isDistrito = false
    }
}
