//
//  SearchViewController.swift
//  PaHis
//
//  Created by ulima on 6/15/19.
//  Copyright © 2019 Maple. All rights reserved.
//

import Firebase
import UIKit
import GoogleMaps

struct DisplayedBuildingPahis {
    let name: String
    let category: String
    let latitude: Double?
    let longitude: Double?
    let distance: Double?
    let imageURL: String?
}

class PlaceListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var categories: [Category] = []
    var displayedBuildingsPahis = [DisplayedBuildingPahis]()
    var originalDisplayedBuildings = [DisplayedBuildingPahis]()
    var filteredBuildingsPahis = [DisplayedBuildingPahis]()
    
    var resultSearchController = UISearchController()
    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation!
    
    var toolBar = UIToolbar()
    var picker: UIPickerView?
    var categoriesList = ["Todos"]
    var selectedCat = "Todos"
    
    @IBOutlet weak var tableView: UITableView!
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Lugares Cercanos"
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = true
        } else {
            // Fallback on earlier versions
        }
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        
        let logoutButtonItem = UIBarButtonItem(image: UIImage(named: "LogoutIcon")?.resizeImageWith(newSize: CGSize(width: 24, height: 24)), style: .plain, target: self, action: #selector(logout))
        self.navigationItem.leftBarButtonItem = logoutButtonItem
        
        let button1 = UIBarButtonItem(image: UIImage(named: "FilterIcon")?.resizeImageWith(newSize: CGSize(width: 22, height: 22)), style: .plain, target: self, action: #selector(filterButtonTapped(_:)))
        let button2 = UIBarButtonItem(image: UIImage(named: "PlusIcon")?.resizeImageWith(newSize: CGSize(width: 22, height: 22)), style: .plain, target: self, action: #selector(navigateToRegister))
        self.navigationItem.setRightBarButtonItems([button2,button1], animated: true)
        
        refreshControl.attributedTitle = NSAttributedString(string: "Actualizando los lugares...")
        refreshControl.addTarget(self, action: #selector(reloadPlaces), for: .valueChanged)
        if #available(iOS 11.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        
        resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            
            tableView.tableHeaderView = controller.searchBar
            
            return controller
        })()
        
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
    }
    
    @IBAction func filterButtonTapped(_ sender: UIButton) {
        guard picker == nil else { return }
        picker = UIPickerView.init()
        picker!.delegate = self
        picker!.backgroundColor = UIColor.white
        picker!.setValue(UIColor.black, forKey: "textColor")
        picker!.autoresizingMask = .flexibleWidth
        picker!.contentMode = .center
        picker!.frame = CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 300)
        picker!.selectRow(categoriesList.firstIndex(of: selectedCat) ?? 0, inComponent: 0, animated: true)
        self.view.addSubview(picker!)
        
        toolBar = UIToolbar.init(frame: CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 50))
        toolBar.items = [UIBarButtonItem.init(title: "Aplicar", style: .done, target: self, action: #selector(onDoneButtonTapped))]
        toolBar.tintColor = UIColor(rgb: 0xF5391C)
        self.view.addSubview(toolBar)
    }
    
    @objc func onDoneButtonTapped() {
        toolBar.removeFromSuperview()
        picker!.removeFromSuperview()
        picker = nil
        displayedBuildingsPahis = originalDisplayedBuildings.filter( {
            return $0.category == selectedCat
        })
        if selectedCat == "Todos" {
            displayedBuildingsPahis = originalDisplayedBuildings
        }
        tableView.reloadData()
        print(selectedCat)
    }
    
    @objc func logout() {
        let alert = UIAlertController(title: "Aviso", message: "¿Está seguro de que desea cerrar su sesión?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Si", style: .default, handler: { _ in
            guard let token = UserDefaults.standard.string(forKey: "token") else { return }
            let spinner = UIViewController.displaySpinner(onView: self.view)
            NetworkManager.shared.logout(token: token) { result in
                switch result {
                case .failure(let error):
                    UIViewController.removeSpinner(spinner: spinner)
                    let alert = UIAlertController(title: "Aviso", message: error.errorDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self.present(alert, animated: true)
                case .success(let message):
                    UIViewController.removeSpinner(spinner: spinner)
                    print(message)
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categoriesList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categoriesList[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCat = categoriesList[row]
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
        label.text = categoriesList[row]
        return label
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func reloadPlaces() {
        fetchBuildings(forced: true)
    }
    
    @objc func navigateToRegister() {
        let sb = UIStoryboard(name: "Register", bundle: nil)
        let vc = sb.instantiateInitialViewController()
        let navigationController = UINavigationController(rootViewController: vc!)
        self.present(navigationController, animated: true)
//        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    func fetchBuildings(forced: Bool = false) {
        let spinner = UIViewController.displaySpinner(onView: self.view)
        NetworkManager.shared.getBuildings(forced: forced) { result in
            switch result {
            case .failure(let error):
                self.refreshControl.endRefreshing()
                UIViewController.removeSpinner(spinner: spinner)
                let alert = UIAlertController(title: "Aviso", message: error.errorDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(alert, animated: true)
            case .success(let categories, let buildings):
                self.categories = categories
                self.categoriesList = ["Todos"] + self.categories.map({ $0.name })
                self.displayedBuildingsPahis = buildings.map({
                    var distance: Double?
                    if $0.latitude != nil && $0.longitude != nil {
                        distance = round(100*((CLLocation(latitude: $0.latitude! as! Double, longitude: $0.longitude! as! Double).distance(from: self.currentLocation))/1000.0))/100
                    }
                    return DisplayedBuildingPahis(name: $0.name, category: $0.category.name, latitude: $0.latitude as? Double, longitude: $0.longitude as? Double, distance: distance, imageURL: $0.images.first)
                })
                self.displayedBuildingsPahis.sort(by: { (b1, b2) -> Bool in
                    return b1.distance ?? Double(Int.max) < b2.distance ?? Double(Int.max)
                })
                self.originalDisplayedBuildings = self.displayedBuildingsPahis
                self.refreshControl.endRefreshing()
                UIViewController.removeSpinner(spinner: spinner)
                self.tableView.reloadData()
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if  (resultSearchController.isActive) {
            return filteredBuildingsPahis.count
        } else {
            return displayedBuildingsPahis.count
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        var building : DisplayedBuildingPahis!
//        if  (resultSearchController.isActive) {
//            building = filteredBuildingsPahis[indexPath.row]
//        } else {
//            building = displayedBuildingsPahis[indexPath.row]
//        }
//        if building.name == "CINE TAURO" {
//            let sb = UIStoryboard(name: "Monumento", bundle: nil)
//            let vc = sb.instantiateViewController(withIdentifier: "CineTauro")
//            self.navigationController?.pushViewController(vc, animated: true)
//        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PlaceTableViewCell.identifier, for: indexPath) as! PlaceTableViewCell
        if (resultSearchController.isActive) {
            cell.place = filteredBuildingsPahis[indexPath.row]
            return cell
        }
        else {
            cell.place = displayedBuildingsPahis[indexPath.row]
            return cell
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filteredBuildingsPahis.removeAll(keepingCapacity: false)
        filteredBuildingsPahis = originalDisplayedBuildings.filter({ $0.name.uppercased().contains(searchController.searchBar.text!.uppercased()) })
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let navigateToGoogleMaps = UITableViewRowAction(style: .normal, title: "Google Maps") { action, index in
            guard UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!) else {
                let alert = UIAlertController(title: "Aviso", message: "No tiene instalado Google Maps en su dispositivo.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(alert, animated: true)
                return
            }
            guard let lat = self.displayedBuildingsPahis[index.row].latitude, let lon = self.displayedBuildingsPahis[index.row].longitude else {
                let alert = UIAlertController(title: "Aviso", message: "El lugar seleccionado no cuenta con ubicación disponible, intente con otro lugar.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(alert, animated: true)
                return
            }
            UIApplication.shared.open(URL(string: "comgooglemaps://?q=\(lat),\(lon)&zoom=14&views=traffic")!)
        }
        let navigateToWaze = UITableViewRowAction(style: .normal, title: "Waze") { (action, index) in
            guard UIApplication.shared.canOpenURL(URL(string:"waze://")!) else {
                let alert = UIAlertController(title: "Aviso", message: "No tiene instalado Waze en su dispositivo.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(alert, animated: true)
                return
            }
            guard let lat = self.displayedBuildingsPahis[index.row].latitude, let lon = self.displayedBuildingsPahis[index.row].longitude else {
                let alert = UIAlertController(title: "Aviso", message: "El lugar seleccionado no cuenta con ubicación disponible, intente con otro lugar.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(alert, animated: true)
                return
            }
            UIApplication.shared.open(URL(string: "waze://?ll=\(lat),\(lon)&navigate=yes)")!)
        }
        navigateToGoogleMaps.backgroundColor = .black
        navigateToWaze.backgroundColor = .lightGray
        return [navigateToWaze, navigateToGoogleMaps]
    }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView,
                   leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        let closeAction = UIContextualAction(style: .normal, title:  "Alertar", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            let sb = UIStoryboard(name: "Alert", bundle: nil)
            let vc = sb.instantiateInitialViewController() as! AlertTableViewController
            var building : DisplayedBuildingPahis!
            if (self.resultSearchController.isActive) {
                building = self.filteredBuildingsPahis[indexPath.row]
            }
            else {
                building = self.displayedBuildingsPahis[indexPath.row]
            }
//            vc.desc = building.desc
//            vc.codBuild = building.codBuild
//            vc.direccion = building.address
            success(true)
//            self.navigationController?.pushViewController(vc, animated: true)
        })
//        closeAction.image = UIImage(named: "tick")
        closeAction.backgroundColor = UIColor(rgb: 0xF5391C)
        
        return UISwipeActionsConfiguration(actions: [closeAction])
        
    }
}

extension PlaceListViewController: CLLocationManagerDelegate {
    
    // Handle incoming location events.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last!
        print("Location: \(location)")
        currentLocation = location
        fetchBuildings(forced: false)
    }
    
    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
        }
    }
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
}

