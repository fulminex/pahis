//
//  LoginViewController.swift
//  PaHis
//
//  Created by ulima on 6/15/19.
//  Copyright © 2019 Maple. All rights reserved.
//

import UIKit
import Firebase

class LoginTableViewController: UITableViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Ingresar"
        let cancelBarButtonItem = UIBarButtonItem(image: UIImage(named: "CancelIcon"), style: .plain, target: self, action: #selector(cancelButtonTapped))
        self.navigationController?.navigationBar.tintColor  = UIColor(rgb: 0xF5391C)
        self.navigationItem.rightBarButtonItem = cancelBarButtonItem
        self.loginButton.backgroundColor = UIColor(rgb: 0xF5391C)
    }
    
    @objc func cancelButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        // Insertar funcion para logearse aqui
        view.endEditing(true)
        let spinner = UIViewController.displaySpinner(onView: self.view)
        guard let email = emailTextField.text, email.contains("@"), email.split(separator: "@").count == 2 else {
            let alert = UIAlertController(title: "Aviso", message: "Ingresa un correo válido.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
            UIViewController.removeSpinner(spinner: spinner)
            self.present(alert, animated: true)
            return
        }
        guard let password = passwordTextField.text, password.count > 6 else {
            let alert = UIAlertController(title: "Aviso", message: "Ingresa una contraseña mayor a 6 caracteres.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
            UIViewController.removeSpinner(spinner: spinner)
            self.present(alert, animated: true)
            return
        }
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            guard error == nil else {
                let alert = UIAlertController(title: "Aviso", message: "Correo y/o contraseña incorrectos.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
                UIViewController.removeSpinner(spinner: spinner)
                self.present(alert, animated: true)
                return
            }
            let firebaseAuth = Auth.auth()
            guard firebaseAuth.currentUser != nil else {
                print("No hay ningun usuario conectado")
                return
            }
            print("usuario logeado exitosamente")
            UIViewController.removeSpinner(spinner: spinner)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
}
