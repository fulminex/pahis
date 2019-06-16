//
//  ListadoAlertaViewController.swift
//  PaHis
//
//  Created by ulima on 6/16/19.
//  Copyright © 2019 Maple. All rights reserved.
//

import Firebase
import UIKit

class ListadoAlertaViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var ref: DatabaseReference!
    var refAlertas: DatabaseReference!
    
    var alertas: [Alerta] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Listado de Alertas"
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = true
        } else {
            // Fallback on earlier versions
        }
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        
        ref = Database.database().reference()
        refAlertas = ref.child("alertas")
        
        fetchAlertas()
    }
    
    func fetchAlertas() {
        refAlertas.observeSingleEvent(of: .value) { (snapshot) in
            guard let registros = snapshot.value as? [String : AnyObject] else { return }
            registros.forEach({ (key, value) in
                guard let registro = value as? [String : AnyObject] else { return }
                registro.forEach({ (key2, value2) in
                    guard let item = value2 as? [String : AnyObject] else { return }
                    let alerta = Alerta(
                        codInmueble: item["codInmueble"] as! String,
                        descripcion: item["descripcion"] as! String,
                        dirección: item["dirección"] as! String,
                        photoRaw: item["photo"] as! String
                    )
                    self.alertas.append(alerta)
                })
                self.tableView.reloadData()
            })
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return alertas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AlertaTableViewCell.identifier, for: indexPath) as! AlertaTableViewCell
        cell.alerta = alertas[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let aceptar = UITableViewRowAction(style: .normal, title: "Archivar") { (action, index) in
            self.alertas.remove(at: index.row)
            tableView.reloadData()
        }
        let rechazar = UITableViewRowAction(style: .normal, title: "Eliminar") { (action, index) in
            self.alertas.remove(at: index.row)
            tableView.reloadData()
        }
        aceptar.backgroundColor = .lightGray
        rechazar.backgroundColor = UIColor(rgb: 0xF5391C)
        return [aceptar,rechazar]
    }
}


