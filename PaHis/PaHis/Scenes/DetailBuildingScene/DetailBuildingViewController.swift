//
//  DetailBuildingViewController.swift
//  PaHis
//
//  Created by Angel Herrera Medina on 9/4/19.
//  Copyright © 2019 Maple. All rights reserved.
//

import UIKit

class DetailsBuildingViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource {

    var building: BuildingPahis!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var addressTextView: UITextView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    func setupView() {
        title = building.name ?? "Este patrimonio no tiene nombre"
        nameLabel.text = building.name ?? "Este patrimonio no tiene nombre"
        descriptionTextView.text = building.buildingDescription ?? "No hay descripción disponible."
        descriptionTextView.adjustContentSize()
        if let category = building.category {
            categoryLabel.text = category.name ?? ""
        }
        addressTextView.text = building.address
        addressTextView.adjustContentSize()
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = 60

        let button = UIBarButtonItem(image: UIImage(named: "edit")?.resizeImageWith(newSize: CGSize(width: 22, height: 22)), style: .plain, target: self, action: #selector(navigateToRegister))
        self.navigationItem.rightBarButtonItem = button
    }
    
    // MARK: - Otras funciones xd
    
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
