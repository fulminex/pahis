//
//  AlertsHistoryViewController.swift
//  PaHis
//
//  Created by Leonardo Luna on 9/26/19.
//  Copyright © 2019 Maple. All rights reserved.
//

import UIKit

class AlertsHistoryViewController: UIViewController {

    @IBOutlet weak var waitingLabel: UILabel!
    @IBOutlet weak var aceptedLabel: UILabel!
    @IBOutlet weak var rejectedLabel: UILabel!
    
    var spinner = UIView()
    var displayedAlerts = [Alert]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Alertas realizadas"
        fetchAlerts()
        // Do any additional setup after loading the view.
    }
    
    func fetchAlerts() {
        spinner = UIViewController.displaySpinner(onView: self.view)
        guard let currentUser = User.currentUser else {
            let alert = UIAlertController(title: "Aviso", message: "Su sessión ha expirado", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            return
        }
        NetworkManager.shared.getAlerts(token: currentUser.token) { result in
            switch result {
            case .failure(let error):
                UIViewController.removeSpinner(spinner: self.spinner)
                let alert = UIAlertController(title: "Aviso", message: error.errorDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(alert, animated: true)
            case .success(let success):
                UIViewController.removeSpinner(spinner: self.spinner)
                self.displayedAlerts = success
                self.waitingLabel.text = String(self.displayedAlerts.filter({ alert in
                    alert.state == "En espera"
                }).count)
                self.aceptedLabel.text = String(self.displayedAlerts.filter({ alert in
                    alert.state == "Aceptada"
                }).count)
                self.rejectedLabel.text = String(self.displayedAlerts.filter({ alert in
                    alert.state == "Rechazada"
                }).count)
            }
            
        }
    }
    

    /*
    // MARK: - Navigation
     Denuncia patrimonio
     Alerta las incidencias que encuentres en los parimonios del Perú.

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
