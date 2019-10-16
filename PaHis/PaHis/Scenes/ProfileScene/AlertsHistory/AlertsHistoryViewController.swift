//
//  AlertsHistoryViewController.swift
//  PaHis
//
//  Created by Leonardo Luna on 9/26/19.
//  Copyright © 2019 Maple. All rights reserved.
//

import UIKit

class AlertsHistoryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var waitingLabel: UILabel!
    @IBOutlet weak var aceptedLabel: UILabel!
    @IBOutlet weak var rejectedLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var yellowView: UIView!
    @IBOutlet weak var grennView: UIView!
    @IBOutlet weak var redView: UIView!
    
    var spinner = UIView()
    var displayedAlerts = [Alert]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Alertas realizadas"
        let width = (view.frame.size.width - 30) / 1
        let cellSize = CGSize(width: width, height: 90)

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = cellSize
        layout.sectionInset = UIEdgeInsets(top: 1, left: 10, bottom: 1, right: 10)
        layout.minimumLineSpacing = 10.0
        layout.minimumInteritemSpacing = 10.0
        collectionView.setCollectionViewLayout(layout, animated: true)
        
        yellowView.layer.cornerRadius = 5
        grennView.layer.cornerRadius = 5
        redView.layer.cornerRadius = 5
        fetchAlerts()
    }
    
    func fetchAlerts() {
        spinner = UIViewController.displaySpinner(onView: self.view)
        guard let currentUser = User.currentUser else {
            let alert = UIAlertController(title: "Aviso", message: "Su sessión ha expirado", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            return
        }
        NetworkManager.shared.getAlerts(token: currentUser.token) { result in
            switch result {
            case .failure(let error):
                UIViewController.removeSpinner(spinner: self.spinner)
                let alert = UIAlertController(title: "Aviso", message: error.errorDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(alert, animated: true)
            case .success(let success):
                UIViewController.removeSpinner(spinner: self.spinner)
                self.displayedAlerts = success
                self.waitingLabel.text = String(self.displayedAlerts.filter({ alert in
                    alert.state == "En espera"
                }).count)
                self.aceptedLabel.text = String(self.displayedAlerts.filter({ alert in
                    alert.state == "Aceptada"
                }).count)
                self.rejectedLabel.text = String(self.displayedAlerts.filter({ alert in
                    alert.state == "Rechazada"
                }).count)
                self.collectionView.reloadData()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return displayedAlerts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let displayedAlert = displayedAlerts[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlertHistoryCollectionViewCell", for: indexPath) as! AlertHistoryCollectionViewCell
        if displayedAlert.state == "En espera" {
            cell.backgroundColor = UIColor(rgb: 0xF2BC29)
        } else if displayedAlert.state == "Aceptada" {
            cell.backgroundColor = UIColor(rgb: 0x42A84B)
        } else if displayedAlert.state == "Rechazada" {
            cell.backgroundColor = UIColor(rgb: 0xA50000)
        }
        
        let details = NSMutableAttributedString(string: "\(displayedAlert.state ?? "")", attributes:
            [
                NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12),
                NSAttributedString.Key.foregroundColor : UIColor.gray
        ])
        details.append(NSAttributedString(string: "\n\(displayedAlert.name ?? "")", attributes:
            [
                NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 17),
                NSAttributedString.Key.foregroundColor : UIColor.white
        ]))
        details.append(NSAttributedString(string: "\n\(displayedAlert.description ?? "")", attributes:
            [
                NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14),
                NSAttributedString.Key.foregroundColor : UIColor.white
        ]))
        
        cell.detailsLabel.attributedText = details
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let alert = displayedAlerts[indexPath.row]
        let sb = UIStoryboard(name: "AlertDetail", bundle: nil)
        let vc = sb.instantiateInitialViewController() as! AlertDetailViewController
        vc.alert = alert
        self.navigationController?.pushViewController(vc, animated: true)
    }

}
