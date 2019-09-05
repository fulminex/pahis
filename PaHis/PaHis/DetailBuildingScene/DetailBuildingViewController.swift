//
//  DetailBuildingViewController.swift
//  PaHis
//
//  Created by Angel Herrera Medina on 9/4/19.
//  Copyright © 2019 Maple. All rights reserved.
//

import UIKit

class DetailsBuildingViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource {

    var building: Building!
    
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
        title = building.name
        nameLabel.text = building.name
        descriptionTextView.text = building.detail
        descriptionTextView.adjustContentSize()
        categoryLabel.text = building.category.name
        addressTextView.text = building.address
        addressTextView.adjustContentSize()
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = 60
    }
    
    // MARK:- Funciones del delegate del collectionView
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return building.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DetailBuildingCollectionViewCell.identifier, for: indexPath) as! DetailBuildingCollectionViewCell
        cell.urlImageRaw = building.images[indexPath.row]
        return cell
    }
    
    // MARK:- Funciones del delegate del tableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return building.documents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DetailBuildingTableViewCell.identifier, for: indexPath) as! DetailBuildingTableViewCell
        cell.documentName = building.documents[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let url = URL(string: building.documents[indexPath.row]) else { return }
        UIApplication.shared.open(url)
    }
}
