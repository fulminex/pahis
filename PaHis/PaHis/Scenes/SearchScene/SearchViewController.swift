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
    
    var pageBuilding: PageBuilding?
    var filteredPage: PageBuilding?
    
    var categories: [CategoryPahis] = []
    var buildings: [BuildingPahis] = []
    var displayedBuildingsPahis = [DisplayedBuildingPahis]()
    var originalDisplayedBuildings = [DisplayedBuildingPahis]()
    var filteredBuildingsPahis = [DisplayedBuildingPahis]()
    
    var page: Int = 1
    var isForced: Bool = true
    
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
        locationManager.distanceFilter = 100
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
    }
    
    @IBAction func filterButtonTapped(_ sender: UIButton) {
        let sb = UIStoryboard(name: "Filters", bundle: nil)
        let vc = sb.instantiateInitialViewController() as! FiltersViewController
        vc.categories = self.categories
        vc.delegate = self
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: true)
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
        pageBuilding = nil
        buildings = []
        self.page = 1
        isForced = true
        fetchBuildings(page: self.page)
    }
    
    @objc func navigateToRegister() {
        let sb = UIStoryboard(name: "Register", bundle: nil)
        let vc = sb.instantiateInitialViewController() as! RegisterTableViewController
        vc.categories = categories
        vc.categoriesName = categories.map({ $0.name! })
        let navigationController = UINavigationController(rootViewController: vc)
        self.present(navigationController, animated: true)
//        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    func fetchBuildings(page: Int, categoriID: String = "", codUbigeo: String = "", lat: String = "", long: String = "") {
        if isForced {
            let spinner = UIViewController.displaySpinner(onView: self.view)
            NetworkManager.shared.getBuildings(page: page, categoriID: categoriID, codUbigeo: codUbigeo, latitud: lat, longitud: long) { result in
                switch result {
                case .failure(let error):
                    self.refreshControl.endRefreshing()
                    UIViewController.removeSpinner(spinner: spinner)
                    let alert = UIAlertController(title: "Aviso", message: error.errorDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self.present(alert, animated: true)
                case .success(let categories, let pageBuilding):
                    self.pageBuilding = pageBuilding
                    self.categories = categories
                    self.buildings += pageBuilding.items!
                    self.categoriesList = ["Todos"] + self.categories.map({ $0.name! })
                    self.displayedBuildingsPahis = self.buildings.map({
                        var distance: Double?
                        if $0.latitude != nil && $0.longitude != nil {
                            distance = round(100*((CLLocation(latitude: $0.latitude! , longitude: $0.longitude! ).distance(from: self.currentLocation))/1000.0))/100
                        }
                        return DisplayedBuildingPahis(name: $0.name!, category: $0.category!.name!, latitude: $0.latitude, longitude: $0.longitude, distance: distance, imageURL: $0.images!.first?.url!)
                    })
                    self.displayedBuildingsPahis.sort(by: { (b1, b2) -> Bool in
                        return b1.distance ?? Double(Int.max) < b2.distance ?? Double(Int.max)
                    })
                    self.originalDisplayedBuildings = self.displayedBuildingsPahis
                    self.refreshControl.endRefreshing()
                    UIViewController.removeSpinner(spinner: spinner)
                    self.isForced = false
                    self.tableView.reloadData()
                }
            }
        } else {
            self.displayedBuildingsPahis = self.buildings.map({
                var distance: Double?
                if $0.latitude != nil && $0.longitude != nil {
                    distance = round(100*((CLLocation(latitude: $0.latitude! , longitude: $0.longitude! ).distance(from: self.currentLocation))/1000.0))/100
                }
                return DisplayedBuildingPahis(name: $0.name!, category: $0.category!.name!, latitude: $0.latitude, longitude: $0.longitude, distance: distance, imageURL: $0.images!.first?.url!)
            })
            self.displayedBuildingsPahis.sort(by: { (b1, b2) -> Bool in
                return b1.distance ?? Double(Int.max) < b2.distance ?? Double(Int.max)
            })
            self.originalDisplayedBuildings = self.displayedBuildingsPahis
            self.tableView.reloadData()
        }
    }
    
    func fetchBuildingsWithFilter(page: Int, query: String, lat: String = "", long: String = "") {
        let spinner = UIViewController.displaySpinner(onView: self.view)
        NetworkManager.shared.getBuildings(page: page, query: query, latitud: lat, longitud: long) { result in
            switch result {
            case .failure(let error):
                self.refreshControl.endRefreshing()
                UIViewController.removeSpinner(spinner: spinner)
                let alert = UIAlertController(title: "Aviso", message: error.errorDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(alert, animated: true)
            case .success(_, let pageBuilding):
                self.filteredPage = pageBuilding
                self.filteredBuildingsPahis = pageBuilding.items!.map({
                    var distance: Double?
                    if $0.latitude != nil && $0.longitude != nil {
                        distance = round(100*((CLLocation(latitude: $0.latitude! , longitude: $0.longitude! ).distance(from: self.currentLocation))/1000.0))/100
                    }
                    return DisplayedBuildingPahis(name: $0.name!, category: $0.category!.name!, latitude: $0.latitude, longitude: $0.longitude, distance: distance, imageURL: $0.images!.first?.url!)
                })
                self.filteredBuildingsPahis.sort(by: { (b1, b2) -> Bool in
                    return b1.distance ?? Double(Int.max) < b2.distance ?? Double(Int.max)
                })
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
        var building : DisplayedBuildingPahis!
        let sb = UIStoryboard(name: "DetailBuilding", bundle: nil)
        let vc = sb.instantiateInitialViewController() as! DetailsBuildingViewController
        if  (resultSearchController.isActive) {
            building = filteredBuildingsPahis[indexPath.row]
            vc.building = filteredPage?.items!.filter({ $0.name == building.name }).first!
        } else {
            building = displayedBuildingsPahis[indexPath.row]
            vc.building = pageBuilding?.items!.filter({ $0.name == building.name }).first!
        }
        resultSearchController.isActive = false
        self.navigationController?.pushViewController(vc, animated: true)
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
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let intTotalrow = tableView.numberOfRows(inSection:indexPath.section)//first get total rows in that section by current indexPath.
        //get last last row of tablview
        if indexPath.row == intTotalrow - 4 {
            guard let pb = pageBuilding else { return }
            if pb.hasNext! {
                isForced = true
                fetchBuildings(page: page + 1, lat: String(currentLocation!.coordinate.latitude), long: String(currentLocation!.coordinate.longitude))
            }
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filteredBuildingsPahis = []
        self.tableView.reloadData()
        fetchBuildingsWithFilter(page: 1, query: searchController.searchBar.text!, lat: String(currentLocation!.coordinate.latitude), long: String(currentLocation!.coordinate.longitude))
//        filteredBuildingsPahis = originalDisplayedBuildings.filter({ $0.name.uppercased().contains(searchController.searchBar.text!.uppercased()) })
//        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        var building : DisplayedBuildingPahis!
        if  (resultSearchController.isActive) {
            building = filteredBuildingsPahis[indexPath.row]
        } else {
            building = displayedBuildingsPahis[indexPath.row]
        }
        let navigateToGoogleMaps = UITableViewRowAction(style: .normal, title: "Google Maps") { action, index in
            guard UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!) else {
                let alert = UIAlertController(title: "Aviso", message: "No tiene instalado Google Maps en su dispositivo.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(alert, animated: true)
                return
            }
            guard let lat = building.latitude, let lon = building.longitude else {
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
            guard let lat = building.latitude, let lon = building.longitude else {
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
            let sb = UIStoryboard(name: "SwipeAlert", bundle: nil)
            let vc = sb.instantiateInitialViewController() as! SwipeAlertTableViewController
            var building : DisplayedBuildingPahis!
            if  (self.resultSearchController.isActive) {
                building = self.filteredBuildingsPahis[indexPath.row]
                vc.building = self.filteredPage?.items!.filter({ $0.name == building.name }).first!
            } else {
                building = self.displayedBuildingsPahis[indexPath.row]
                vc.building = self.pageBuilding?.items!.filter({ $0.name == building.name }).first!
            }
//            vc.desc = building.desc
//            vc.codBuild = building.codBuild
//            vc.direccion = building.address
            success(true)
            self.navigationController?.pushViewController(vc, animated: true)
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
        fetchBuildings(page: self.page, lat: String(currentLocation!.coordinate.latitude), long: String(currentLocation!.coordinate.longitude))
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

extension PlaceListViewController: FilterPopUpDelegate {
    func getFilter(filter: Filter) {
        pageBuilding = nil
        buildings = []
        self.page = 1
        isForced = true
        fetchBuildings(page: self.page, categoriID: filter.categoryID ?? "", codUbigeo: filter.codUbigeo ?? "", lat: String(currentLocation!.coordinate.latitude), long: String(currentLocation!.coordinate.longitude))
    }
}
