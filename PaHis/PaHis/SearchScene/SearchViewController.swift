//
//  SearchViewController.swift
//  PaHis
//
//  Created by ulima on 6/15/19.
//  Copyright © 2019 Maple. All rights reserved.
//

import UIKit
import GoogleMaps

struct DisplayedPlace {
    let name: String
    let latitud: String?
    let longitud: String?
    let distance: Double?
    let imageUrl: URL
}

class PlaceListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var places: [Place] = []
    var displayedPlaces: [DisplayedPlace] = []
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation!
    var forced: Bool = true
    
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
        
        refreshControl.attributedTitle = NSAttributedString(string: "Actualizando los lugares...")
        refreshControl.addTarget(self, action: #selector(reloadPlaces), for: .valueChanged)
        if #available(iOS 11.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func reloadPlaces() {
        fetchPlaces(forced: true)
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
        return displayedPlaces.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PlaceTableViewCell.identifier, for: indexPath) as! PlaceTableViewCell
        cell.place = displayedPlaces[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let navigateToGoogleMaps = UITableViewRowAction(style: .normal, title: "Google Maps") { action, index in
            guard UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!) else {
                let alert = UIAlertController(title: "Aviso", message: "No tiene instalado Google Maps en su dispositivo.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(alert, animated: true)
                return
            }
            guard let latitude = self.displayedPlaces[index.row].latitud, let lat = Double(latitude), let longitude = self.displayedPlaces[index.row].longitud, let lon = Double(longitude) else {
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
            guard let latitude = self.displayedPlaces[index.row].latitud, let lat = Double(latitude), let longitude = self.displayedPlaces[index.row].longitud, let lon = Double(longitude) else {
                let alert = UIAlertController(title: "Aviso", message: "El lugar seleccionado no cuenta con ubicación disponible, intente con otro lugar.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(alert, animated: true)
                return
            }
            UIApplication.shared.open(URL(string: "waze://?ll=\(lat),\(lon)&navigate=yes)")!)
        }
        navigateToGoogleMaps.backgroundColor = .blue
        navigateToWaze.backgroundColor = .orange
        return [navigateToWaze, navigateToGoogleMaps]
    }
}

extension PlaceListViewController: CLLocationManagerDelegate {
    
    // Handle incoming location events.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last!
        print("Location: \(location)")
        currentLocation = location
        fetchPlaces(forced: forced)
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

