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
    
    override func viewWillAppear(_ animated: Bool) {
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            guard user != nil else { return }
            
            //Poner tabbar aqui!!
            
            UITabBar.appearance().tintColor = UIColor.black
            UITabBar.appearance().backgroundImage = UIImage()
            UITabBar.appearance().shadowImage = UIImage()
//            UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
//            UINavigationBar.appearance().shadowImage = UIImage()
//            UINavigationBar.appearance().backgroundColor = .white
//            UINavigationBar.appearance().isTranslucent = false
            
            var controllers: [UIViewController] = []
            
            let storyBoard = UIStoryboard(name: "Map", bundle:nil)
            let mapVC = storyBoard.instantiateInitialViewController()!
            mapVC.tabBarItem = UITabBarItem(title: "Mapa", image: UIImage(named: "MapIcon")?.resizeImageWith(newSize: CGSize(width: 33, height: 33)), tag: 0)
//            mapVC.tabBarItem.imageInsets = UIEdgeInsets(top: 9, left: 0, bottom: -9, right: 0)
            mapVC.title = "Mapa"
//            mapVC.navigationItem.titleView?.isHidden = true
//            mapVC.navigationItem.title = nil
            controllers.append(mapVC)
            
            let searchSB = UIStoryboard(name: "Search", bundle:nil)
            let searchVC = searchSB.instantiateInitialViewController()!
            searchVC.tabBarItem = UITabBarItem(title: "Buscar" , image: UIImage(named: "SearchIcon")?.resizeImageWith(newSize: CGSize(width: 33, height: 33)), tag: 1)
            searchVC.title = "Buscar"
            controllers.append(UINavigationController(rootViewController: searchVC))
//            searchVC?.tabBarItem.imageInsets = UIEdgeInsets(top: 9, left: 0, bottom: -9, right: 0)
            
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
            
//            let controllersWithoutNavigation = [mapVC, searchVC]
//            let controllersWithNavigation = [mapVC, searchVC]
            
            let tabBarController = UITabBarController()
            tabBarController.viewControllers = controllers //controllersWithNavigation.map { UINavigationController(rootViewController: $0 as! UIViewController) }
            tabBarController.selectedIndex = 0
            tabBarController.tabBar.backgroundColor = .white
            //tabBarController.tabBar.items?.forEach({ $0.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -16) })
            
//            self.window?.rootViewController = tabBarController
//            self.window?.makeKeyAndVisible()
            
            //let ChatListVC = //ChatListCollectionViewController(collectionViewLayout: UICollectionViewFlowLayout())
            self.present(tabBarController, animated: true, completion: nil)
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
