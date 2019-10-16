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
    
    static var selectedCategory: CategoryPahis?
    static var selectedDepartment: Ubigeo?
    static var selectedProvincia: Ubigeo?
    static var selectedDistrito: Ubigeo?
    
    var prevCategory: CategoryPahis?
    var prevDepartment: Ubigeo?
    var prevProvincia: Ubigeo?
    var prevDistrito: Ubigeo?
    
    var categories: [CategoryPahis]!
    var departments: [Ubigeo]?
    var provincias: [Ubigeo]?
    var distritos: [Ubigeo]?
    
    static var categoryValue: Int = 0
    static var departmentValue: Int = 0
    static var provinciaValue: Int = 0
    static var distritoValue: Int = 0
    
    var prevCategoryValue: Int = 0
    var prevDepartmentValue: Int = 0
    var prevProvinciaValue: Int = 0
    var prevDistritoValue: Int = 0
    
    var delegate: FilterPopUpDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFileds()
        fetchDepartments()
    }
    
    func setupFileds() {
        if let category = FiltersViewController.selectedCategory {
            categoryButton.setTitle(category.name, for: .normal)
            prevCategory = category
        }
        if let department = FiltersViewController.selectedDepartment {
            departmentButton.setTitle(department.nombre, for: .normal)
            prevDepartment = department
        }
        if let provincia = FiltersViewController.selectedProvincia {
            provinciaButton.setTitle(provincia.nombre, for: .normal)
            prevProvincia = provincia
        }
        if let distrito = FiltersViewController.selectedDistrito {
            distritoButton.setTitle(distrito.nombre, for: .normal)
            prevDistrito = distrito
        }
        prevCategoryValue = FiltersViewController.categoryValue
        prevDepartmentValue = FiltersViewController.departmentValue
        prevProvinciaValue = FiltersViewController.provinciaValue
        prevDistritoValue = FiltersViewController.distritoValue
    }
    
    @IBAction func applyButtonPressed(_ sender: UIButton) {
        var codUbigeo: String? = nil
        if FiltersViewController.selectedDepartment != nil {
            codUbigeo = String(String(FiltersViewController.selectedDepartment!.codUbigeo!).prefix(2))
            if FiltersViewController.selectedProvincia != nil {
                codUbigeo = String(String(FiltersViewController.selectedProvincia!.codUbigeo!).prefix(4))
                if FiltersViewController.selectedDistrito != nil {
                    codUbigeo = String(FiltersViewController.selectedDistrito!.codUbigeo!)
                }
            }
        }
        delegate.getFilter(filter: Filter(categoryID: FiltersViewController.selectedCategory != nil ? String(FiltersViewController.selectedCategory!.id!) : nil , codUbigeo: codUbigeo))
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButton(_ sender: UIButton) {
        FiltersViewController.selectedCategory = prevCategory
        FiltersViewController.selectedDepartment = prevDepartment
        FiltersViewController.selectedProvincia = prevProvincia
        FiltersViewController.selectedDistrito = prevDistrito

        FiltersViewController.distritoValue = prevDistritoValue
        FiltersViewController.departmentValue = prevDepartmentValue
        FiltersViewController.provinciaValue = prevProvinciaValue
        FiltersViewController.distritoValue = prevDistritoValue
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func categoryButtonPressed(_ sender: UIButton) {
        isCategory = true
        openPicker(items: ["Todas"] + categories.map({ $0.name! }), index: FiltersViewController.categoryValue)
    }
    
    @IBAction func departmentButtonPressedç(_ sender: UIButton) {
        guard departments != nil else { return }
        isDepartment = true
        openPicker(items: ["Todos"] + departments!.map({ $0.nombre! }), index: FiltersViewController.departmentValue)
    }
    
    @IBAction func provinciaButtonPressed(_ sender: UIButton) {
        guard provincias != nil else {
            let alert = UIAlertController(title: "Aviso", message: "Selecciona primero un departamento", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        isProvincia = true
        openPicker(items: ["Todas"] + provincias!.map({ $0.nombre! }), index: FiltersViewController.provinciaValue)
    }
    
    @IBAction func distritoButtonPressed(_ sender: UIButton) {
        guard distritos != nil else {
            let alert = UIAlertController(title: "Aviso", message: "Selecciona primero una provincia", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        isDistrito = true
        openPicker(items: ["Todos"] + distritos!.map({ $0.nombre! }), index: FiltersViewController.distritoValue)
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
        let id = String(FiltersViewController.selectedDepartment!.codUbigeo!).prefix(2)
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
        let id = String(FiltersViewController.selectedProvincia!.codUbigeo!).prefix(4)
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
    
    func openPicker(items: [String],index: Int) {
        let sb = UIStoryboard(name: "Picker", bundle: nil)
        let vc = sb.instantiateInitialViewController() as! PickerViewController
        vc.items = items
        vc.index = index
        vc.delegate = self
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overCurrentContext
        self.present(vc, animated: true)
    }
    
}

extension FiltersViewController: PopUpPickerViewDelegate {
    func getItemSelected(value: String, index: Int) {
        if isCategory {
            isCategory = false
            FiltersViewController.categoryValue = index
            categoryButton.setTitle(value, for: .normal)
            guard value != "Todas" else {
                FiltersViewController.selectedCategory = nil
                return
            }
            FiltersViewController.selectedCategory = categories?.filter({ $0.name == value }).first!
        }
        if isDepartment {
            FiltersViewController.departmentValue = index
            isDepartment = false
            departmentButton.setTitle(value, for: .normal)
            guard value != "Todos" else {
                FiltersViewController.selectedDepartment = nil
                FiltersViewController.selectedProvincia = nil
                FiltersViewController.selectedDistrito = nil
                provinciaButton.setTitle("Todas", for: .normal)
                distritoButton.setTitle("Todos", for: .normal)
                return
            }
            FiltersViewController.selectedDepartment = departments?.filter({ $0.nombre == value }).first!
            FiltersViewController.selectedProvincia = nil
            FiltersViewController.selectedDistrito = nil
            provinciaButton.setTitle("Todas", for: .normal)
            distritoButton.setTitle("Todos", for: .normal)
            fetchProvincias()
        }
        if isProvincia {
            FiltersViewController.provinciaValue = index
            isProvincia = false
            provinciaButton.setTitle(value, for: .normal)
            guard value != "Todas" else {
                FiltersViewController.selectedProvincia = nil
                FiltersViewController.selectedDistrito = nil
                distritoButton.setTitle("Todos", for: .normal)
                return
            }
            FiltersViewController.selectedProvincia = provincias?.filter({ $0.nombre == value }).first!
            FiltersViewController.selectedDistrito = nil
            distritoButton.setTitle("Todos", for: .normal)
            fetchDistritos()
        }
        if isDistrito {
            FiltersViewController.provinciaValue = index
            isDistrito = false
            distritoButton.setTitle(value, for: .normal)
            guard value != "Todos" else {
                FiltersViewController.selectedDistrito = nil
                return
            }
            FiltersViewController.selectedDistrito = distritos?.filter({ $0.nombre == value }).first!
        }
    }
    
    func cancelButtonPressed(){
        isCategory = false
        isDepartment = false
        isProvincia = false
        isDistrito = false
    }
}
