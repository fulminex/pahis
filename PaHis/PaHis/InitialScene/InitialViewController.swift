//
//  InitialViewController.swift
//  PaHis
//
//  Created by Leo on 6/15/19.
//  Copyright © 2019 Maple. All rights reserved.
//

import UIKit
import Firebase

class InitialViewController: UIViewController {
    
    var handle: AuthStateDidChangeListenerHandle?
    @IBOutlet var InitialView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        InitialView.backgroundColor = UIColor(rgb: 0xF5391C)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let token = UserDefaults.standard.string(forKey: "token")
        if token != nil && token != "" {
            print("Token de Sesión: ", token)
            let spinner = UIViewController.displaySpinner(onView: self.view)
            
            UITabBar.appearance().tintColor = UIColor.black
            UITabBar.appearance().backgroundImage = UIImage()
            UITabBar.appearance().shadowImage = UIImage()
            UINavigationBar.appearance().tintColor = UIColor(rgb: 0xF5391C)
            
            let urlUserString = "https://4d96388d.ngrok.io/api/user/\(token!)"
            let urlUser = URL(string: urlUserString)!
            
            let request = URLRequest(url: urlUser)
            
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
                    print(responseJSON)
                    if let error = responseJSON["error"] as? String {
                        UIViewController.removeSpinner(spinner: spinner)
                        let alert = UIAlertController(title: "Aviso", message: "Error: \(error)", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
                        self.present(alert, animated: true)
                    } else {
                        guard let userTypeJSON = responseJSON["user_type"] as? [String: Any], let nameType = userTypeJSON["name"] as? String else {
                            UIViewController.removeSpinner(spinner: spinner)
                            let alert = UIAlertController(title: "Aviso", message: "No se encontró el tipo de usuario.", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
                            self.present(alert, animated: true)
                            return
                        }
                        
                        print("====================",nameType)
                        DispatchQueue.main.async {
                            UIViewController.removeSpinner(spinner: spinner)
                            self.createTabBarController(nameType: nameType)
                        }
                    }
                }
            }
            task.resume()
        }
    }
    
    func createTabBarController(nameType: String) {
        var controllers: [UIViewController] = []
        
        let storyBoard = UIStoryboard(name: "Map", bundle:nil)
        let mapVC = storyBoard.instantiateInitialViewController()!
        mapVC.tabBarItem = UITabBarItem(title: "Mapa", image: UIImage(named: "MapIcon")?.resizeImageWith(newSize: CGSize(width: 33, height: 33)), tag: 0)
        mapVC.title = "Mapa"
        controllers.append(mapVC)
        
        let searchSB = UIStoryboard(name: "Search", bundle:nil)
        let searchVC = searchSB.instantiateInitialViewController()!
        searchVC.tabBarItem = UITabBarItem(title: "Buscar" , image: UIImage(named: "SearchIcon")?.resizeImageWith(newSize: CGSize(width: 33, height: 33)), tag: 1)
        searchVC.title = "Buscar"
        controllers.append(UINavigationController(rootViewController: searchVC))
        
        if nameType == "Voluntario" {
            let adhocSB = UIStoryboard(name: "AdHoc", bundle: nil)
            let adhocVC = adhocSB.instantiateInitialViewController()!
            adhocVC.tabBarItem = UITabBarItem(title: "Alertas" , image: UIImage(named: "AdhocIcon")?.resizeImageWith(newSize: CGSize(width: 33, height: 33)), tag: 4)
            adhocVC.title = "Alertas"
            controllers.append(UINavigationController(rootViewController: adhocVC))
        }
        
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = controllers
        tabBarController.selectedIndex = 0
        tabBarController.tabBar.backgroundColor = .white
        
        self.present(tabBarController, animated: true, completion: nil)
    }

    @IBAction func loginButtonTapped(_ sender: Any) {
        let loginStoryboard = UIStoryboard(name: "Login", bundle: nil)
        let loginVC = loginStoryboard.instantiateViewController(withIdentifier: "LoginViewController")
        self.present(UINavigationController(rootViewController: loginVC), animated: true, completion: nil)
    }
    
    @IBAction func newAccountButtonTapped(_ sender: Any) {
        let createUserStoryboard = UIStoryboard(name: "CreateUser", bundle: nil)
        let createUserVC = createUserStoryboard.instantiateViewController(withIdentifier: "CreateUserViewController")
        self.present(UINavigationController(rootViewController: createUserVC), animated: true, completion: nil)
    }

}
