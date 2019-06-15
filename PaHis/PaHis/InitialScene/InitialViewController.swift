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

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            guard user != nil else { return }
            
            //Poner tabbar aqui!!
            
            UITabBar.appearance().tintColor = UIColor.black
            UITabBar.appearance().backgroundImage = UIImage()
            UITabBar.appearance().shadowImage = UIImage()
            UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
            UINavigationBar.appearance().shadowImage = UIImage()
            UINavigationBar.appearance().backgroundColor = .white
            UINavigationBar.appearance().isTranslucent = false
            
            let storyBoard = UIStoryboard(name: "Main", bundle:nil)
            let initialVC = storyBoard.instantiateViewController(withIdentifier: "InitialViewController")
            initialVC.tabBarItem = UITabBarItem(title: "INICIO", image: nil, tag: 0)
            initialVC.title = "INICIO"
            initialVC.navigationItem.titleView?.isHidden = true
            initialVC.navigationItem.title = nil
            
//            let filterVC = storyBoard.instantiateViewController(withIdentifier: "FilterViewController") as! FirstViewController
//            filterVC.tabBarItem = UITabBarItem(title: "FILTROS", image: nil, tag: 1)
//            filterVC.title = "FILTROS"
//
//            let searchVC = storyBoard.instantiateViewController(withIdentifier: "SearchViewController") as! SecondViewController
//            searchVC.tabBarItem = UITabBarItem(title: "BUSCAR", image: nil, tag: 2)
//            searchVC.title = "BUSCAR"
//
//            let investigationVC = storyBoard.instantiateViewController(withIdentifier: "InvestigationViewController") as! InvestigacionViewController
//            investigationVC.tabBarItem = UITabBarItem(title: "INVESTIGACIÓN", image: nil, tag: 3)
//            investigationVC.title = "INVESTIGACIÓN"
            
            let controllersWithoutNavigation = [initialVC]
//            let controllersWithNavigation = [filterVC, searchVC, investigationVC]
            
            let tabBarController = UITabBarController()
            tabBarController.viewControllers = controllersWithoutNavigation // + controllersWithNavigation.map { UINavigationController(rootViewController: $0) }
            tabBarController.selectedIndex = 0
            tabBarController.tabBar.backgroundColor = .white
            tabBarController.tabBar.items?.forEach({ $0.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -16) })
            
//            self.window?.rootViewController = tabBarController
//            self.window?.makeKeyAndVisible()
            
            //let ChatListVC = //ChatListCollectionViewController(collectionViewLayout: UICollectionViewFlowLayout())
            self.present(UINavigationController(rootViewController: tabBarController), animated: true, completion: nil)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handle!)
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
    
    /*
     // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
