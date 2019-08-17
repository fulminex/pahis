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
            print("Token de Sesión: ", token!)
            let spinner = UIViewController.displaySpinner(onView: self.view)
            NetworkManager.shared.getUserInfo(token: token!) { result in
                switch result {
                case .failure(let error):
                    UIViewController.removeSpinner(spinner: spinner)
                    let alert = UIAlertController(title: "Aviso", message: error.errorDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self.present(alert, animated: true)
                case .success(let userTypeName):
                    UIViewController.removeSpinner(spinner: spinner)
                    self.createTabBarController(userTypeName: userTypeName)
                }
            }
        }
    }
    
    func createTabBarController(userTypeName: String) {
        
        UITabBar.appearance().tintColor = UIColor.black
        UITabBar.appearance().backgroundImage = UIImage()
        UITabBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().tintColor = UIColor(rgb: 0xF5391C)
        
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
        
        if userTypeName == "Voluntario" {
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
