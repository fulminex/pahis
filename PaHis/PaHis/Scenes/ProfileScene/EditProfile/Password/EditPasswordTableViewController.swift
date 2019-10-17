//
//  EditPasswordTableViewController.swift
//  PaHis
//
//  Created by Leonardo Luna on 9/26/19.
//  Copyright © 2019 Maple. All rights reserved.
//

import UIKit

class EditPasswordTableViewController: UITableViewController {

    @IBOutlet weak var currentPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var reNewPasswordTxt: UITextField!
    
    var spinner = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        
    }

    @IBAction func changePassword(_ sender: UIButton) {
        spinner = UIViewController.displaySpinner(onView: self.view)
        view.endEditing(true)
        guard let currentPassword = currentPasswordTextField.text, currentPassword.count != 0 else {
            let alert = UIAlertController(title: "Aviso", message: "Ingresa tu contraseña actual.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
            UIViewController.removeSpinner(spinner: spinner)
            self.present(alert, animated: true)
            return
        }
        guard let newPassword = newPasswordTextField.text, newPassword.count != 0 else {
            let alert = UIAlertController(title: "Aviso", message: "Ingresa tu nueva contraseña.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
            UIViewController.removeSpinner(spinner: spinner)
            self.present(alert, animated: true)
            return
        }
        guard let rePass = reNewPasswordTxt.text, newPassword == rePass else {
            let alert = UIAlertController(title: "Aviso", message: "Las contraseñas nuevas no coinciden.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
            UIViewController.removeSpinner(spinner: spinner)
            self.present(alert, animated: true)
            return
        }
        guard let currentUser = User.currentUser else {
            let alert = UIAlertController(title: "Aviso", message: "Su sessión ha expirado", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            return
        }
        NetworkManager.shared.updatePassword(token: currentUser.token, currentPassword: currentPassword, newPassword: newPassword) { result in
            switch result {
            case .failure(let error):
                UIViewController.removeSpinner(spinner: self.spinner)
                let alert = UIAlertController(title: "Aviso", message: error.errorDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
                self.present(alert, animated: true)
            case .success(let success):
                UIViewController.removeSpinner(spinner: self.spinner)
                let alert = UIAlertController(title: "Aviso", message: success, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: { _ in
                   self.navigationController?.popViewController(animated: true)
                }))
                self.present(alert, animated: true)
            }
        }
    }

}
