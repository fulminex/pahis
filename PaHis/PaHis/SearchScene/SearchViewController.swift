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

struct DisplayedPlace {
    let name: String
    let latitud: String?
    let longitud: String?
    let distance: Double?
    let imageUrl: URL
}

class PlaceListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {
    
    var ref: DatabaseReference!
    var categoriesRef: DatabaseReference!
    var categoriesHandle: DatabaseHandle!
    var inmueblesRef: DatabaseReference!
    var inmueblesRefHandle: DatabaseHandle!
    
    var categories: [Category] = []
    var displayedBuildings: [Building] = []
    var filteredBuildings = [Building]()
    var resultSearchController = UISearchController()
    
    var places: [Place] = []
    var displayedPlaces: [DisplayedPlace] = []
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation!
    var forced: Bool = true
    
    @IBOutlet weak var tableView: UITableView!
    private let refreshControl = UIRefreshControl()
    
    var spinner: UIView!
    
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
        
        let button1 = UIBarButtonItem(image: UIImage(named: "FilterIcon")?.resizeImageWith(newSize: CGSize(width: 22, height: 22)), style: .plain, target: self, action: nil)
        let button2 = UIBarButtonItem(image: UIImage(named: "PlusIcon")?.resizeImageWith(newSize: CGSize(width: 22, height: 22)), style: .plain, target: self, action: nil)
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
        
        ref = Database.database().reference()
        categoriesRef = ref.child("categorias")
        inmueblesRef = ref.child("inmueblesLima")
        
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
        spinner = UIViewController.displaySpinner(onView: self.view)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func reloadPlaces() {
        fetchPlaces(forced: true)
    }
    
    func fetchCategories(forced: Bool) {
        if forced {
            categoriesRef.observeSingleEvent(of: .value) { (snapshot) in
                if let array = snapshot.value as? [[String: Any]] {
                    for aValue in array {
                        let name = aValue["NOMBRE"] as? String ?? "-"
                        let codCatString = aValue["codCategoria"] as? String ?? "-"
                        let category = Category(name: name, codCategory: codCatString)
                        self.categories.append(category)
                    }
                    self.inmueblesRef.observeSingleEvent(of: .value, with: { (snapshot2) in
                        if let array = snapshot2.value as? [[String: Any]] {
                            for aValue in array {
                                let codInm = aValue["codInmueble"] as? String ?? "-"
                                print(codInm)
                                let desc = aValue["descripcion"] as? String ?? "-"
                                let codDist = aValue["codDistrito"] as? String ?? "-"
                                let obser = aValue["observacion"] as? String ?? "-"
                                let codCat = aValue["codCategoria"] as? String ?? "-"
                                var category: Category?
                                self.categories.forEach({
                                    if $0.codCategory == codCat {
                                        category = $0
                                    }
                                })
                                
                                let x = aValue["X"] as? String ?? "-"
                                let y = aValue["Y"] as? String ?? "-"
                                let zona = aValue["zona"] as? String ?? "-"
                                let latitud = aValue["LATITUD"] as? String
                                let longitud = aValue["LONGITUD"] as? String
                                let addr = aValue["direccion"] as? String ?? "-"
                                let fachada = aValue["FACHADA"] as? String ?? "-"
                                let tipoNorm = aValue["tipoDeNorma"] as? String ?? "-"
                                let numNorma = aValue["numDeNorma"] as? String ?? "-"
                                let archiv = aValue["archivoDeNorma"] as? String ?? "-"
                                
                                let distancia: Double?
                                
                                if latitud != nil && longitud != nil {
                                    print(latitud)
                                    print(longitud)
                                    let lat = Double(latitud!)!
                                    let lon = Double(longitud!)!
                                    let location = CLLocation(latitude: lat, longitude: lon)
                                    distancia = round(100*((location.distance(from: self.currentLocation))/1000.0))/100
                                } else {
                                    distancia = nil
                                }
                                
                                let build = Building(
                                    codBuild: codInm,
                                    desc: desc,
                                    codDist: codDist,
                                    obser: obser,
                                    category: category!,
                                    x: x,
                                    y: y,
                                    zone: zona,
                                    latitudeRaw: latitud,
                                    longitudeRaw: longitud,
                                    address: addr,
                                    fachada: fachada,
                                    tipNorma: tipoNorm,
                                    numNorma: numNorma,
                                    archiNorma: archiv,
                                    distancia: distancia
                                )
                                if !self.displayedBuildings.contains(where: { $0.codBuild == codInm }) {
                                    self.displayedBuildings.append(build)
                                }
                            }
                            self.displayedBuildings.sort(by: { (p1, p2) -> Bool in
                                return p1.distancia ?? Double(Int.max) < p2.distancia ?? Double(Int.max)
                            })
                            self.forced = false
                            UIViewController.removeSpinner(spinner: self.spinner)
                            self.tableView.reloadData()
                        }
                    })
                }
            }
        }
        
    }
    
    func fetchPlaces(forced: Bool) {
        if forced {
            let request = URLRequest(url: Place.apiURL)
            let _ = URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard response != nil else {
                    print("Error, no hay respuesta")
                    return
                }
                guard let data = data else {
                    print("Error, no hay data")
                    return
                }
                let decoder = JSONDecoder()
                do {
                    self.places = try decoder.decode([Place].self, from: data)
                    print("Se realizó petición al server")
                    self.forced = false
                    self.displayedPlaces = self.places.map({
                        DisplayedPlace(
                            name: $0.nombre,
                            latitud: $0.coord?.latitud == "" ? nil : $0.coord?.latitud,
                            longitud: $0.coord?.longitud == "" ? nil : $0.coord?.longitud,
                            distance: $0.location?.distance(from: self.currentLocation) != nil ? round(100*(($0.location?.distance(from: self.currentLocation) ?? 0.0)/1000.0))/100 : nil,
                            imageUrl: $0.imageUrl)
                    })
                    self.displayedPlaces.sort(by: { (p1, p2) -> Bool in
                        return p1.distance ?? Double(Int.max) < p2.distance ?? Double(Int.max)
                    })
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.refreshControl.endRefreshing()
                    }
                } catch {
                    print("Error al hacer decode")
                }
                }.resume()
        } else {
            self.displayedPlaces = self.places.map({
                DisplayedPlace(
                    name: $0.nombre,
                    latitud: $0.coord?.latitud == "" ? nil : $0.coord?.latitud,
                    longitud: $0.coord?.longitud == "" ? nil : $0.coord?.longitud,
                    distance: $0.location?.distance(from: self.currentLocation) != nil ? round(100*(($0.location?.distance(from: self.currentLocation) ?? 0.0)/1000.0))/100 : nil,
                    imageUrl: $0.imageUrl)
            })
            print("Se actualizó las distancias")
            self.displayedPlaces.sort(by: { (p1, p2) -> Bool in
                return p1.distance ?? Double(Int.max) < p2.distance ?? Double(Int.max)
            })
            self.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if  (resultSearchController.isActive) {
            return filteredBuildings.count
        } else {
            return displayedBuildings.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PlaceTableViewCell.identifier, for: indexPath) as! PlaceTableViewCell
        if (resultSearchController.isActive) {
            cell.place = filteredBuildings[indexPath.row]
            return cell
        }
        else {
            cell.place = displayedBuildings[indexPath.row]
            return cell
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filteredBuildings.removeAll(keepingCapacity: false)
        filteredBuildings = displayedBuildings.filter({ $0.desc.uppercased().contains(searchController.searchBar.text!.uppercased()) })
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
            guard let latitude = self.displayedBuildings[index.row].latitudeRaw, let lat = Double(latitude), let longitude = self.displayedBuildings[index.row].longitudeRaw, let lon = Double(longitude) else {
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
            guard let latitude = self.displayedBuildings[index.row].latitudeRaw, let lat = Double(latitude), let longitude = self.displayedBuildings[index.row].longitudeRaw, let lon = Double(longitude) else {
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
            print("OK, marked as Closed")
            success(true)
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
        fetchCategories(forced: forced)
        //fetchPlaces(forced: forced)
        tableView.reloadData()
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

