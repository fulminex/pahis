//
//  CineTauroViewController.swift
//  PaHis
//
//  Created by Leo on 6/16/19.
//  Copyright © 2019 Maple. All rights reserved.
//

import UIKit
import Firebase

class CineTauroViewController: UIViewController {
    
    @IBOutlet weak var textUITextfield: UITextView!
    @IBOutlet weak var autorLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    
    var userRole: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        autorLabel.textColor = UIColor(rgb: 0xF5391C)
        yearLabel.textColor = UIColor(rgb: 0xF5391C)
        validateUser()
    }
    
    func validateUser() {
        guard let currentuser = Auth.auth().currentUser else {
            return
        }
        
        let ref = Database.database().reference()
        let usersRef = ref.child("users")
        let userRef = usersRef.child(currentuser.uid)
        userRef.observeSingleEvent(of: .value) { (snapshot) in
            guard let user = snapshot.value as? [String: AnyObject] else {
                return
            }
            self.userRole = user["userType"] as! String
        }
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
