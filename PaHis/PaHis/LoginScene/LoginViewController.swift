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
        
        let urlLoginString = "https://4d96388d.ngrok.io/api/login?email=\(email)&password=\(password)"
        let urlLogin = URL(string: urlLoginString)!
        
        var request = URLRequest(url: urlLogin)
        request.httpMethod = "POST"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                UIViewController.removeSpinner(spinner: spinner)
                let alert = UIAlertController(title: "Aviso", message: "Error: \(error?.localizedDescription ?? "No data")", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
                self.present(alert, animated: true)
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                UIViewController.removeSpinner(spinner: spinner)
                print(responseJSON)
                if let error = responseJSON["error"] as? String {
                    let alert = UIAlertController(title: "Aviso", message: "Error: \(error)", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
                    self.present(alert, animated: true)
                } else {
                    guard let token = responseJSON["token"] as? String else {
                        let alert = UIAlertController(title: "Aviso", message: "Error al generar el token de sesión.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
                        self.present(alert, animated: true)
                        return
                    }
                    UserDefaults.standard.set(token, forKey: "token")
                    print("usuario logeado exitosamente")
                    self.dismiss(animated: true, completion: nil)
                }
            } else {
                UIViewController.removeSpinner(spinner: spinner)
                
            }
        }
        task.resume()
    }
    
}
