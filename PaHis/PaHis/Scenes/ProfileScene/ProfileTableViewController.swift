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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logoutButton.backgroundColor = .black
        alertsLabel.textColor = UIColor(rgb: 0xF5391C)
        alertsDescriptionLabel.textColor = UIColor(rgb: 0xF5391C)
        setupGesture()
        fillUserInfo()
        self.refreshControl?.addTarget(self, action: #selector(refreshInfo), for: .valueChanged)
        self.tableView.addSubview(self.refreshControl!)
        let cancelBarButtonItem = UIBarButtonItem(image: UIImage(named: "settings")?.resizeImageWith(newSize: CGSize(width: 32.0, height: 32.0)), style: .plain, target: self, action: #selector(settingsTapped))
        self.navigationController?.navigationBar.tintColor  = UIColor(rgb: 0xF5391C)
        self.navigationItem.rightBarButtonItem = cancelBarButtonItem
    }
    
    func setupGesture() {
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(navigateToAlertsHistory(sender:)))
        alertsLabel.isUserInteractionEnabled = true
        alertsLabel.addGestureRecognizer(tap1)
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(navigateToAlertsHistory(sender:)))
        alertsDescriptionLabel.isUserInteractionEnabled = true
        alertsDescriptionLabel.addGestureRecognizer(tap2)
    }
    
    @objc func navigateToAlertsHistory(sender:UITapGestureRecognizer) {
        let sb = UIStoryboard(name: "AlertsHistory", bundle: nil)
        let vc = sb.instantiateInitialViewController() as! AlertsHistoryViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func refreshInfo() {
        guard let currentUser = User.currentUser else {
            let alert = UIAlertController(title: "Aviso", message: "Su sessión ha expirado", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            return
        }
        NetworkManager.shared.getUser(forced: true, token: currentUser.token) { result in
            switch result {
            case .failure(let error):
                self.refreshControl?.endRefreshing()
                let alert = UIAlertController(title: "Aviso", message: error.errorDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(alert, animated: true)
            case .success( _):                
                self.fillUserInfo()
            }
            
        }
//        fillUserInfo()
    }
    
    @objc func settingsTapped() {
        let sb = UIStoryboard(name: "EditOptions", bundle: nil)
        let vc = sb.instantiateInitialViewController() as! EditOptionsTableViewController
        let navVc = UINavigationController(rootViewController: vc)
        navVc.modalPresentationStyle = .fullScreen
        self.present(navVc, animated: true, completion: nil)
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
        if let url = URL(string: currentUser.profilePicUrlRaw) {
            photoImageVIew.layer.cornerRadius = self.photoImageVIew.frame.size.width / 2
            photoImageVIew.clipsToBounds = true
            photoImageVIew.contentMode = .scaleAspectFill
            photoImageVIew.kf.indicatorType = .activity
            photoImageVIew.kf.setImage(with: url)
        }

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
        alert.addAction(UIAlertAction(title: "Sí", style: .destructive, handler: { _ in
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
