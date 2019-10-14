//
//  PickerViewController.swift
//
//  Created by Angel Herrera on 9/10/19.
//  Copyright © 2019 SudTechnologies. All rights reserved.
//

import UIKit

protocol PopUpPickerViewDelegate {
    func getItemSelected(value: String,index: Int)
    func cancelButtonPressed()
}

class PickerViewController: UIViewController {
    
    var items: [String]!
    var index: Int!
    var itemSelected = ""
    
    var delegate: PopUpPickerViewDelegate!
    
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    func setupView(){
        pickerView.delegate = self
        self.itemSelected = items.first ?? ""
        pickerView.selectRow(index, inComponent: 0, animated: true)
    }
    
    @IBAction func okButtonPressed(_ sender: Any) {
        let itemIndex = pickerView.selectedRow(inComponent: 0)
        delegate.getItemSelected(value: self.itemSelected, index: itemIndex)
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func cancelButtonPressed(_ sender: Any) {
        delegate.cancelButtonPressed()
        self.dismiss(animated: true, completion: nil)
    }
}

extension PickerViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return items.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return items[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        itemSelected = items[row]
    }
}
