//
//  MapViewController.swift
//  PaHis
//
//  Created by ulima on 6/15/19.
//  Copyright © 2019 Maple. All rights reserved.
//

import UIKit
import MapKit
import GoogleMaps

class POIItem: NSObject, GMUClusterItem {
    var position: CLLocationCoordinate2D
    var name: String!
    
    init(position: CLLocationCoordinate2D, name: String) {
        self.position = position
        self.name = name
    }
}

class MapViewController: UIViewController, GMUClusterManagerDelegate, GMSMapViewDelegate,  GMUClusterRendererDelegate {
    
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation?
    var mapView: GMSMapView!
    var zoomLevel: Float = 12.0
    let distanceFilter: Double = 100.0
    
    @IBOutlet weak var navigationButton: UIButton!
    var selectedMarker: GMSMarker?
    
    private var clusterManager: GMUClusterManager!
    
    let defaultLocation = CLLocation(latitude: -12.0266034, longitude: -77.1278631)
    
    var buildings = [BuildingPahis]()
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        navigationController?.setNavigationBarHidden(true, animated: animated)
//    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        navigationController?.setNavigationBarHidden(false, animated: animated)
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        
        let camera = GMSCameraPosition.camera(withLatitude: defaultLocation.coordinate.latitude,
                                              longitude: defaultLocation.coordinate.longitude,
                                              zoom: zoomLevel)
        mapView = GMSMapView.map(withFrame: view.bounds, camera: camera)
        mapView.settings.myLocationButton = true
        mapView.settings.compassButton = true
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.isMyLocationEnabled = true
        
        do {
            // Set the map style by passing the URL of the local file.
            if let styleURL = Bundle.main.url(forResource: "style", withExtension: "json") {
                mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                NSLog("Unable to find style.json")
            }
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
        
        // Add the map to the view, hide it until we've got a location update.
        view.addSubview(mapView)
        mapView.isHidden = true
        
        // Set up the cluster manager with default icon generator and renderer.
        //let iconGenerator = GMUDefaultClusterIconGenerator(buckets: [5, 10, 15, 20, 25], backgroundImages: [#imageLiteral(resourceName: "ufo"),#imageLiteral(resourceName: "ufo"),#imageLiteral(resourceName: "ufo"),#imageLiteral(resourceName: "ufo"),#imageLiteral(resourceName: "ufo")])
        let iconGenerator = GMUDefaultClusterIconGenerator(buckets: [5, 10, 15, 20, 25], backgroundColors: [.gray,.gray,.gray,.gray,.gray])
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        let renderer = GMUDefaultClusterRenderer(mapView: mapView, clusterIconGenerator: iconGenerator)
        renderer.delegate = self
        
        clusterManager = GMUClusterManager(map: mapView, algorithm: algorithm, renderer: renderer)
        
        // Register self to listen to both GMUClusterManagerDelegate and GMSMapViewDelegate events.
        clusterManager.setDelegate(self, mapDelegate: self)
        
        addPath()
        setupNavigationButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchPlaces() {
        NetworkManager.shared.getBuildings(page: 1, latitud: String(currentLocation!.coordinate.latitude), longitud: String(currentLocation!.coordinate.longitude)) { result in
            switch result {
            case.failure(let error):
                print(error)
            case.success((_, let page )):
                self.buildings = page.items!
                self.createMarkers()
            }
        }
    }
    
    func setupNavigationButton() {
        view.bringSubviewToFront(navigationButton)
        navigationButton.addTarget(self, action: #selector(navigationButtonTapped), for: .touchUpInside)
        navigationButton.isHidden = true
    }
    
    @objc func navigationButtonTapped(){
        let canOpenGoogleMaps = UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)
        let canOpenWaze       = UIApplication.shared.canOpenURL(URL(string:"waze://")!)
        switch (canOpenGoogleMaps, canOpenWaze) {
        case (true, true):
            let alert = UIAlertController(title: "Aviso", message: "Elige una aplicación para realizar tu ruta", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Google Maps", style: .default, handler: { (action) in
                self.goWithGoogleMaps()
            }))
            alert.addAction(UIAlertAction(title: "Waze", style: .default, handler: { (action) in
                self.goWithWaze()
            }))
            alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
            if let popoverPresentationController = alert.popoverPresentationController {
                popoverPresentationController.sourceView = self.view
                popoverPresentationController.sourceRect = CGRect(x: 0, y: 0, width: 1, height: 1)
            }
            self.present(alert, animated: true)
        case (true, false):
            goWithGoogleMaps()
        case (false, true):
            goWithWaze()
        default:
            let alert = UIAlertController(title: "Aviso", message: "No tienes Google Maps ni Waze instalado", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
            self.present(alert, animated: true)
        }
    }
    
    func goWithGoogleMaps() {
        guard let marker = selectedMarker else { return }
        UIApplication.shared.open(URL(string: "comgooglemaps://?q=\(marker.position.latitude),\(marker.position.longitude)&zoom=14&views=traffic")!)
    }
    
    func goWithWaze() {
        guard let marker = selectedMarker else { return }
        UIApplication.shared.open(URL(string: "waze://?ll=\(marker.position.latitude),\(marker.position.longitude)&navigate=yes")!)
    }
    
    func goWithMaps() {
        guard let marker = selectedMarker else { return }
        let regionDistance:CLLocationDistance = 10000
        let coordinates = marker.position
        let regionSpan = MKCoordinateRegion.init(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = marker.title
        mapItem.openInMaps(launchOptions: options)
    }
    
    func createMarkers() {
        clusterManager.clearItems()
        generateClusterItems()
        clusterManager.cluster()
    }
    
    private func generateClusterItems() {
        buildings.forEach ({
            guard let latitud = $0.latitude else { return }
            guard let longitud = $0.longitude else { return }
            let coordinate = CLLocationCoordinate2D(latitude: latitud, longitude: longitud)
            let item = POIItem(position: coordinate, name: $0.name!)
            clusterManager.add(item)
        })
    }
    
    // MARK: - GMUClusterManagerDelegate
    func clusterManager(_ clusterManager: GMUClusterManager, didTap cluster: GMUCluster) -> Bool {
        let newCamera = GMSCameraPosition.camera(withTarget: cluster.position, zoom: mapView.camera.zoom + 1)
        mapView.animate(to: newCamera)
        return false
    }
    
    // MARK: - GMUMapViewDelegate
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        NSLog("Did tap a coordinate in map")
        UIView.animate(withDuration: 0.2, delay: 0, options: [], animations: {
            self.navigationButton.alpha = 0
        }) { _ in
            self.navigationButton.isHidden = true
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if let poiItem = marker.userData as? POIItem {
            NSLog("Did tap marker for cluster item \(String(describing: poiItem.name))")
            selectedMarker = marker
            marker.title = poiItem.name
            let location = CLLocation(latitude: poiItem.position.latitude, longitude: poiItem.position.longitude)
            let distanceInKilometers = round(100*((currentLocation?.distance(from: location) ?? 0.0)/1000.0))/100
            marker.snippet = "Ubicado a \(distanceInKilometers) Kilometros"
            self.navigationButton.isHidden = false
            self.navigationButton.alpha = 0
            UIView.animate(withDuration: 0.2, delay: 0, options: [], animations: {
                self.navigationButton.alpha = 1
            })
        } else {
            NSLog("Did tap a normal marker")
            UIView.animate(withDuration: 0.2, delay: 0, options: [], animations: {
                self.navigationButton.alpha = 0
            }) { _ in
                self.navigationButton.isHidden = true
            }
        }
        return false
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        if let building = buildings.first(where: {$0.name == marker.title!}) {
            let sb = UIStoryboard(name: "DetailBuilding", bundle: nil)
            let vc = sb.instantiateInitialViewController() as! DetailsBuildingViewController
            vc.building = building
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // MARK: - GMUClusterRendererDelegate
    func renderer(_ renderer: GMUClusterRenderer, willRenderMarker marker: GMSMarker) {
        guard let poiItem = marker.userData as? POIItem else { return }
        //        marker.title = poiItem.name
        //        let location = CLLocation(latitude: poiItem.position.latitude, longitude: poiItem.position.longitude)
        //        let distanceInKilometers = round(100*((currentLocation?.distance(from: location) ?? 0.0)/1000.0))/100
        //        marker.snippet = "Ubicado a \(distanceInKilometers) Kilometros"
        marker.icon = GMSMarker.markerImage(with: nil)
        marker.icon = GMSMarker.markerImage(with: .black)
    }
    
    func addPath() {
        let path = GMSMutablePath()
        let limits = Map.limits
        limits.forEach({
            path.add(CLLocationCoordinate2D(latitude: $0[1], longitude: $0[0]))
        })
        let rectangle = GMSPolyline(path: path)
        rectangle.strokeWidth = 2.0
        rectangle.strokeColor = UIColor(named: "RojoPahis")!
        rectangle.map = self.mapView
    }
}

// MARK: - CLLocationManagerDelegate
// Delegates to handle events for the location manager.
extension MapViewController: CLLocationManagerDelegate {
    
    // Handle incoming location events.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        print("Location: \(location)")
        currentLocation = location
        
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: zoomLevel)
        
        if mapView.isHidden {
            mapView.isHidden = false
            mapView.camera = camera
        } else {
            mapView.animate(to: camera)
        }
        self.fetchPlaces()
    }
    
    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            // Display the map using the default location.
            mapView.isHidden = false
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
