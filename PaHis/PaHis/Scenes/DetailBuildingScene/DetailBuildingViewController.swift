//
//  DetailBuildingViewController.swift
//  PaHis
//
//  Created by Angel Herrera Medina on 9/4/19.
//  Copyright © 2019 Maple. All rights reserved.
//

import UIKit
import Agrume
import Kingfisher
import MapKit

class DetailsBuildingViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource {

    var building: BuildingPahis!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var detailHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var heightTableViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var documentsTitleLabel: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    func setupView() {
        title = building.name ?? "Este patrimonio no tiene nombre"
        nameLabel.text = building.name ?? "Este patrimonio no tiene nombre"
        descriptionLabel.text = building.buildingDescription ?? "No hay descripción disponible."
        
        if let category = building.category {
            categoryLabel.text = category.name ?? ""
        }
        addressLabel.text = building.address
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = 60
        
        if let lat = building.latitude, let long = building.longitude {
            let location = CLLocationCoordinate2D(latitude: lat,
                                                  longitude: long)
            
            let region = MKCoordinateRegion(center: location, latitudinalMeters: 500, longitudinalMeters: 500)
                mapView.setRegion(region, animated: true)
            let annotation = MKPointAnnotation()
            annotation.coordinate = location
            annotation.title = building.name ?? "Sin nombre"
            annotation.subtitle = building.category?.name ?? "Sin categoría"
            mapView.addAnnotation(annotation)
        } else {
            mapView.isHidden = true
        }
        
        if building.documents!.isEmpty {
            documentsTitleLabel.isHidden = true
            heightTableViewConstraint.constant = 0
            tableView.isHidden = true
        }
        
        let button = UIBarButtonItem(image: UIImage(named: "edit")?.resizeImageWith(newSize: CGSize(width: 22, height: 22)), style: .plain, target: self, action: #selector(navigateToRegister))
        self.navigationItem.rightBarButtonItem = button
    }
    
    // MARK: - Otras funciones xd
    
    func heightForLabel(text:String, font:UIFont, width:CGFloat) -> CGFloat
    {
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text

        label.sizeToFit()



        return label.frame.height

    }
    
    @objc func navigateToRegister() {
        let sb = UIStoryboard(name: "Register", bundle: nil)
        let vc = sb.instantiateInitialViewController() as! RegisterTableViewController
        vc.building = building
//        vc.categories = categories
//        vc.categoriesName = categories.map({ $0.name! })
//        let navigationController = UINavigationController(rootViewController: vc)
        self.navigationController?.pushViewController(vc, animated: true)
//        self.present(navigationController, animated: true)
        //        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    // MARK:- Funciones del delegate del collectionView
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return building.images!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DetailBuildingCollectionViewCell.identifier, for: indexPath) as! DetailBuildingCollectionViewCell
        cell.urlImageRaw = self.building.images![indexPath.row].url
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var urls = [URL]()
        self.building.images?.forEach({
            if let url = URL(string: $0.url!) {
                urls.append(url)
            }
        })
        let agrume = Agrume(urls: urls, startIndex: indexPath.item, background: .blurred(.dark))
        agrume.didScroll = { [unowned self] index in
          self.collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: [], animated: false)
        }
        agrume.show(from: self)
    }
    
    // MARK:- Funciones del delegate del tableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return building.documents!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DetailBuildingTableViewCell.identifier, for: indexPath) as! DetailBuildingTableViewCell
        cell.documentName = building.documents![indexPath.row].url
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let url = URL(string: building.documents![indexPath.row].url!)else { return }
        UIApplication.shared.open(url)
    }
}
