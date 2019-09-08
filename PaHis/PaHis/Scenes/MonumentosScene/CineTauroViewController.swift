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
    @IBOutlet weak var lockIconUIImage: UIImageView!
    @IBOutlet weak var delegadoLabel: UILabel!
    @IBOutlet weak var infoTextField: UITextView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    
    var userRole: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
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
            print(self.userRole)
            if self.userRole == "Ad Hoc" {
                self.delegadoLabel.isHidden = false
                self.lockIconUIImage.isHidden = false
            }
        }
    }
    
    func setView() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(lockPressed(tapGestureRecognizer:)))
        lockIconUIImage.isUserInteractionEnabled = true
        lockIconUIImage.addGestureRecognizer(tapGestureRecognizer)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: UIResponder.keyboardWillHideNotification, object: nil)
        

    }
    
    func createTool() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.dismissKeyboard))
        
        toolBar.setItems([doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        textUITextfield.inputAccessoryView = toolBar
    }
    
    func createTool2() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.dismissKeyboard))
        
        toolBar.setItems([doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        infoTextField.inputView = toolBar
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
        self.lockIconUIImage.image = UIImage(named: "lock")
        infoTextField.inputView = .none
        textUITextfield.inputAccessoryView = .none
    }
    
    @objc func lockPressed(tapGestureRecognizer: UITapGestureRecognizer) {
        textUITextfield.isEditable = true
        infoTextField.isEditable = true
//        createTool()
//        createTool2()
        addDoneButtonOnKeyboard()
        addDoneButtonOnKeyboard2()
        lockIconUIImage.image = UIImage(named: "unlock")
    }
    
    @objc func keyboardWillAppear(_ notification: NSNotification) {
        keyboardShownChanged(notification: notification, show: true)
    }
    
    @objc func keyboardWillDisappear(_ notification: NSNotification) {
        keyboardShownChanged(notification: notification, show: false)
    }
    
    func keyboardShownChanged(notification: NSNotification, show: Bool) {
        let userInfo = notification.userInfo
        
        let keyboardHeight       = (show ? ((userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.size.height) : 0)
        let animationDuration    = (userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.25
        
        var options = UIView.AnimationOptions()
        if let animationCurveRaw = (userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.uintValue {
            options = UIView.AnimationOptions(rawValue: UInt(animationCurveRaw << 16))
        }
        
        view.layoutIfNeeded()
        UIView.animate(
            withDuration: animationDuration, delay: 0.0, options: options,
            animations: {
                if !show {
                    self.bottomConstraint.constant = 100
                } else {
                    self.bottomConstraint.constant = keyboardHeight + 10
                    self.bottomConstraint.constant = keyboardHeight - 40
                }
                self.view.layoutIfNeeded()
        },
            completion: nil
        )
    }
    
    func addDoneButtonOnKeyboard(){
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Listo", style: .done, target: self, action: #selector(self.doneButtonAction))
        
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        textUITextfield.inputAccessoryView = doneToolbar
    }
    
    func addDoneButtonOnKeyboard2(){
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Listo", style: .done, target: self, action: #selector(self.doneButtonAction))
        
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        infoTextField.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction(){
        view.endEditing(true)
        textUITextfield.inputAccessoryView = .none
        infoTextField.inputAccessoryView = .none
        self.bottomConstraint.constant = 0
        self.lockIconUIImage.image = UIImage(named: "locked")
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
