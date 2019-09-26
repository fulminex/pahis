//
//  ProfileTableViewController.swift
//  PaHis
//
//  Created by Leonardo Luna on 9/25/19.
//  Copyright © 2019 Maple. All rights reserved.
//

import UIKit
import Kingfisher

class ProfileTableViewController: UITableViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var photoImageVIew: UIImageView!
    @IBOutlet weak var userInfoLabel: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var alertsLabel: UILabel!
    @IBOutlet weak var sendedContributionsLabel: UILabel!
    @IBOutlet weak var acceptedontributionsLabel: UILabel!
    @IBOutlet weak var alertsDescriptionLabel: UILabel!
    
//    lazy var refreshControl: UIRefreshControl = {
//        let refreshControl = UIRefreshControl()
//        refreshControl.addTarget(self, action:
//                     #selector(ViewController.handleRefresh(_:)),
//                     for: UIControlEvents.valueChanged)
//        refreshControl.tintColor = UIColor.red
//
//        return refreshControl
//    }()
//    override var refreshControl: UIRefreshControl?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logoutButton.backgroundColor = .black
        alertsLabel.textColor = UIColor(rgb: 0xF5391C)
        alertsDescriptionLabel.textColor = UIColor(rgb: 0xF5391C)
        fillUserInfo()
//        self.refreshControl?.addTarget((self, action: #selector(refreshInfo), for: .valueChanged))
//        self.tableView.addSubview(self.refreshControl)
        self.refreshControl?.addTarget(self, action: #selector(refreshInfo), for: .valueChanged)
        self.tableView.addSubview(self.refreshControl!)
    }
    
    @objc func refreshInfo() {
        fillUserInfo()
    }
    
    func fillUserInfo() {
        guard let currentUser = User.currentUser else {
            let alert = UIAlertController(title: "Aviso", message: "Su sessión ha expirado", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            return
        }
        let userName = NSMutableAttributedString(string: "\(currentUser.name)", attributes:
            [
                NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 17),
                NSAttributedString.Key.foregroundColor : UIColor.black
            ])
        userName.append(NSAttributedString(string: "\n\(currentUser.type)", attributes:
            [
                NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15),
                NSAttributedString.Key.foregroundColor : UIColor.lightGray
            ]))
        nameLabel.attributedText = userName
        photoImageVIew.layer.cornerRadius = self.photoImageVIew.frame.size.width / 2
        photoImageVIew.clipsToBounds = true
        photoImageVIew.contentMode = .scaleAspectFill
        photoImageVIew.kf.indicatorType = .activity
        photoImageVIew.kf.setImage(with: currentUser.profilePicUrl!)
        self.tableView.tableFooterView = UIView()
        
        let details = NSMutableAttributedString(string: "Correo electrónico", attributes:
            [
                NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 17),
                NSAttributedString.Key.foregroundColor : UIColor(rgb: 0xF5391C)
        ])
        details.append(NSAttributedString(string: "\n\(currentUser.email)", attributes:
            [
                NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17),
                NSAttributedString.Key.foregroundColor : UIColor.gray
        ]))
        details
            .append(NSMutableAttributedString(string: "\n\nFecha de creación", attributes:
                [
                    NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 17),
                    NSAttributedString.Key.foregroundColor : UIColor(rgb: 0xF5391C)
            ]))
        details.append(NSAttributedString(string: "\n\(currentUser.dateCreated)", attributes:
            [
                NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17),
                NSAttributedString.Key.foregroundColor : UIColor.gray
        ]))
        userInfoLabel.attributedText = details
        fetchNumberOfContributions(token: currentUser.token)
    }
    
    func fetchNumberOfContributions(token: String) {
        let spinner = UIViewController.displaySpinner(onView: self.view)
        NetworkManager.shared.getNumberOfContributions(token: token) { result in
            switch result {
            case .failure(let error):
                UIViewController.removeSpinner(spinner: spinner)
                self.refreshControl?.endRefreshing()
                let alert = UIAlertController(title: "Aviso", message: error.errorDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(alert, animated: true)
            case .success(let success):
                UIViewController.removeSpinner(spinner: spinner)
                self.refreshControl?.endRefreshing()
                self.alertsLabel.text = String(success[0].count)
                self.sendedContributionsLabel.text = String(success[1].count)
                self.acceptedontributionsLabel.text = String(success[2].count)
            }
            
        }
    }
    
    @IBAction func logoutButton(_ sender: UIButton) {
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
    
}
