//
//  ListadoRegistroViewController.swift
//  PaHis
//
//  Created by ulima on 6/16/19.
//  Copyright © 2019 Maple. All rights reserved.
//

import Firebase
import UIKit

class ListadoRegistroViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var ref: DatabaseReference!
    var refRegistros: DatabaseReference!
    
    var registros: [Registro] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Solicitudes de Registro"
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = true
        } else {
            // Fallback on earlier versions
        }
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        
        ref = Database.database().reference()
        refRegistros = ref.child("registros")
        
        fetchRegistros()
    }
    
    func fetchRegistros() {
        refRegistros.observeSingleEvent(of: .value) { (snapshot) in
            guard let registros = snapshot.value as? [String : AnyObject] else { return }
            registros.forEach({ (key, value) in
                guard let registro = value as? [String : AnyObject] else { return }
                registro.forEach({ (key2, value2) in
                    guard let item = value2 as? [String : AnyObject] else { return }
                    let registro = Registro(
                        categoria: item["categoria"] as! String,
                        descripcion: item["descripcion"] as! String,
                        direccion: item["direccion"] as! String,
                        distrito: item["distrito"] as! String,
                        estado: item["estado"] as! String,
                        observaciones: item["observaciones"] as! String,
                        photoRaw: item["photo"] as! String
                    )
                    self.registros.append(registro)
                })
                self.tableView.reloadData()
            })
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return registros.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RegistroTableViewCell.identifier, for: indexPath) as! RegistroTableViewCell
        cell.registro = registros[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let aceptar = UITableViewRowAction(style: .normal, title: "Aceptar") { (action, index) in
            self.registros.remove(at: index.row)
            tableView.reloadData()
        }
        let rechazar = UITableViewRowAction(style: .normal, title: "Rechazar") { (action, index) in
            self.registros.remove(at: index.row)
            tableView.reloadData()
        }
        aceptar.backgroundColor = .lightGray
        rechazar.backgroundColor = UIColor(rgb: 0xF5391C)
        return [aceptar,rechazar]
    }
}
