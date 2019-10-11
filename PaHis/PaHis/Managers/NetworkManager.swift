//
//  NetworkManager.swift
//  PaHis
//
//  Created by Angel Herrera Medina on 8/16/19.
//  Copyright © 2019 Maple. All rights reserved.
//

import Foundation

enum NetworkError: Error {
    case noData(String)
    case noResponse
    case noTokenFound
    case noUserTypeFound
    case webserviceError(String)
    case categoryNoFound
    
    var errorDescription: String {
        switch self {
        case .noData(let error): return "Error al conectar con el servidor. \(error)"
        case .noResponse: return "Error en la respuesta del servidor."
        case .noTokenFound: return "Error al generar el token de sesión."
        case .noUserTypeFound: return "Error al obtener el tipo de usuario."
        case .webserviceError(let error): return error
        case .categoryNoFound: return "Error: no se encontró la categoría."
        }
    }
    
}

class NetworkManager {
    
    private init () {}
    static let shared = NetworkManager()
    let baseURL = "https://pahis-desafio-uno.herokuapp.com/api/"
    
    let persistanceManager = PersistenceManager.shared
    
    func login(email: String, password: String, completion: @escaping (Result<String,NetworkError>) -> Void) {
        let path = "login"
        let url = URL(string: baseURL + path)!
        var request = URLRequest(url: url)
        request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let body: [String:Any] = ["email": email,
                                  "password": password
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    completion(.failure(.noData(error!.localizedDescription)))
                }
                return
            }
            let jsonObject = try? JSONSerialization.jsonObject(with: data, options: [])
            guard let responseJSON = jsonObject as? [String: Any] else {
                DispatchQueue.main.async {
                    completion(.failure(.noResponse))
                }
                return
            }
            if let error = responseJSON["error"] as? String {
                DispatchQueue.main.async {
                    completion(.failure(.webserviceError(error)))
                }
            } else {
                guard let token = responseJSON["token"] as? String else {
                    DispatchQueue.main.async {
                        completion(.failure(.noTokenFound))
                    }
                    return
                }
                DispatchQueue.main.async {
                    completion(.success(token))
                }
            }
        }
        task.resume()
    }
    
    func createUser(name: String, email: String, userType: String, profilePicURL: String, password: String, completion: @escaping (Result<String,NetworkError>) -> Void) {
        let json: [String: Any] = ["name": name,
                                   "email": email,
                                   "user_type": userType,
                                   "profile_pic_url": profilePicURL,
                                   "password": password]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        let path = "user"
        let url = URL(string: baseURL + path)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    completion(.failure(.noData(error!.localizedDescription)))
                }
                return
            }
            let jsonObject = try? JSONSerialization.jsonObject(with: data, options: [])
            guard let responseJSON = jsonObject as? [String: Any] else {
                DispatchQueue.main.async {
                    completion(.failure(.noResponse))
                }
                return
            }
            if let error = responseJSON["error"] as? String {
                DispatchQueue.main.async {
                    completion(.failure(.webserviceError(error)))
                }
            } else {
                DispatchQueue.main.async {
                    completion(.success("Usuario creado satisfactoriamente."))
                }
            }
        }
        task.resume()
    }
    
    func getUser(forced: Bool = false, token: String, completion: @escaping (Result<User,NetworkError>) -> Void) {
        let user = persistanceManager.fetch(User.self).filter({ $0.token == token })
        if forced || user.isEmpty {
            let path = "user/\(token)"
            let url = URL(string: baseURL + path)!
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    DispatchQueue.main.async {
                        completion(.failure(.noData(error!.localizedDescription)))
                    }
                    return
                }
                let jsonObject = try? JSONSerialization.jsonObject(with: data, options: [])
                guard let responseJSON = jsonObject as? [String: Any] else {
                    DispatchQueue.main.async {
                        completion(.failure(.noResponse))
                    }
                    return
                }
                if let error = responseJSON["error"] as? String {
                    DispatchQueue.main.async {
                        completion(.failure(.webserviceError(error)))
                    }
                } else {
                    guard let type = responseJSON["user_type"] as? String else {
                        DispatchQueue.main.async {
                            completion(.failure(.noUserTypeFound))
                        }
                        return
                    }
                    guard let uid = responseJSON["id"] as? Int32, let name = responseJSON["name"] as? String, let email = responseJSON["email"] as? String, let dateCreatedRaw = responseJSON["date_created"] as? String
                        , let profilePicUrlRaw = responseJSON["profile_pic_url"] as? String else {
                        DispatchQueue.main.async {
                            completion(.failure(.noResponse))
                        }
                        return
                    }
                    let user = self.persistanceManager.fetchSingleOrCreate(User.self, uid: uid)
                    user.name = name
                    user.email = email
                    user.profilePicUrlRaw = profilePicUrlRaw
                    user.type = type
                    user.token = token
                    let dateFormatterGet = DateFormatter()
                    dateFormatterGet.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
                    if let date = dateFormatterGet.date(from: dateCreatedRaw) {
                        user.dateCreatedRaw = date
                    } else {
                        user.dateCreatedRaw = dateFormatterGet.date(from: "2001-01-01T01:48:07.883497")!
                    }
                    _ = self.persistanceManager.fetch(User.self).filter({ !$0.hasChanges }).forEach({ self.persistanceManager.delete($0) })
                    self.persistanceManager.save()
                    DispatchQueue.main.async {
                        completion(.success(user))
                    }
                }
            }
            task.resume()
        } else {
            completion(.success(user.first!))
        }
        
    }
    
    func logout(token: String, completion: @escaping (Result<String,NetworkError>) -> Void) {
        let path = "logout?token=\(token)"
        let url = URL(string: baseURL + path)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    completion(.failure(.noData(error!.localizedDescription)))
                }
                return
            }
            let jsonObject = try? JSONSerialization.jsonObject(with: data, options: [])
            guard let responseJSON = jsonObject as? [String: Any] else {
                DispatchQueue.main.async {
                    completion(.failure(.noResponse))
                }
                return
            }
            if let error = responseJSON["error"] as? String {
                DispatchQueue.main.async {
                    completion(.failure(.webserviceError(error)))
                }
            } else {
                guard let message = responseJSON["message"] as? String else {
                    DispatchQueue.main.async {
                        completion(.failure(.noResponse))
                    }
                    return
                }
                UserDefaults.standard.set("", forKey: "token")
                _ = self.persistanceManager.fetch(User.self).forEach({ self.persistanceManager.delete($0) })
                _ = self.persistanceManager.fetch(Category.self).forEach({ self.persistanceManager.delete($0) })
                self.persistanceManager.save()
                DispatchQueue.main.async {
                    completion(.success(message))
                }
            }
        }
        task.resume()
    }
    
    func getBuildings(page: Int, query: String = "", categoriID: String = "", codUbigeo: String = "", nameUbigeo: String = "", latitud: String = "", longitud: String = "", completion: @escaping (Result<([CategoryPahis],PageBuilding),NetworkError>) -> Void) {
        NetworkManager.shared.getCategories() { result in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            case .success(let categories):
                let urlQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                let path = "inmuebles_query?page=\(page)&per_page=20&query=\(urlQuery)&category_id=\(categoriID)&latitude=\(latitud)&longitude=\(longitud)&cod_ubigeo=\(codUbigeo)"
                let url = URL(string: self.baseURL + path)!
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    guard let data = data, error == nil else {
                        DispatchQueue.main.async {
                            completion(.failure(.noData(error!.localizedDescription)))
                        }
                        return
                    }
                    let page = try? JSONDecoder().decode(PageBuilding.self, from: data)
                    DispatchQueue.main.async {
                        completion(.success((categories, page!)))
                    }
                }
                task.resume()
            }
        }
    }
    
    func getCategories(completion: @escaping (Result<[CategoryPahis],NetworkError>) -> Void) {
        let path = "categories"
        let url = URL(string: baseURL + path)!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(.noData(error!.localizedDescription)))
                return
            }
            let categoriesPahis = try? JSONDecoder().decode([CategoryPahis].self, from: data)
            completion(.success(categoriesPahis!))
        }
        task.resume()
    }
    
    func getDepartments(completion: @escaping (Result<[Ubigeo],NetworkError>) -> Void) {
        let path = "departamentos"
        let url = URL(string: baseURL + path)!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(.noData(error!.localizedDescription)))
                return
            }
            let ubigeo = try? JSONDecoder().decode([Ubigeo].self, from: data)
            completion(.success(ubigeo!))
        }
        task.resume()
    }
    
    func getProvincias(departmentID: String, completion: @escaping (Result<[Ubigeo],NetworkError>) -> Void) {
        let path = "provincias/\(departmentID)"
        let url = URL(string: baseURL + path)!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(.noData(error!.localizedDescription)))
                return
            }
            let ubigeo = try? JSONDecoder().decode([Ubigeo].self, from: data)
            completion(.success(ubigeo!))
        }
        task.resume()
    }
    
    func getDistritos(id: String, completion: @escaping (Result<[Ubigeo],NetworkError>) -> Void) {
        let path = "distritos/\(id)"
        let url = URL(string: baseURL + path)!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(.noData(error!.localizedDescription)))
                return
            }
            let ubigeo = try? JSONDecoder().decode([Ubigeo].self, from: data)
            completion(.success(ubigeo!))
        }
        task.resume()
    }
    
    func createBuilding(token:String, name: String, coordinate: (latitude: Double, longitude: Double), address: String, description: String, category: Int, images: [[String:String]], documents: [[String:String]], completion: @escaping (Result<String, NetworkError>) -> Void) {
        
        NetworkManager.shared.uploadDocuments(files: images) { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let imageURLs):
                NetworkManager.shared.uploadDocuments(files: documents) { result in
                    switch result {
                    case .failure(let error):
                        completion(.failure(error))
                    case .success(let documentURLs):
                        let path = "inmueble"
                        let url = URL(string: self.baseURL + path)!
                        var request = URLRequest(url: url)
                        request.httpMethod = "POST"
                        request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
                        let json: [String: Any] = [
                            "token": token,
                            "name": name,
                            "latitude": coordinate.latitude,
                            "longitude": coordinate.longitude,
                            "address": address,
                            "description": description,
                            "category": category,
                            "images": imageURLs,
                            "documents": documentURLs
                        ]
                        let jsonData = try? JSONSerialization.data(withJSONObject: json)
                        request.httpBody = jsonData
                        let task = URLSession.shared.dataTask(with: request) { data, response, error in
                            guard let data = data, error == nil else {
                                DispatchQueue.main.async {
                                    completion(.failure(.noData(error!.localizedDescription)))
                                }
                                return
                            }
                            let jsonObject = try? JSONSerialization.jsonObject(with: data, options: [])
                            guard let responseJSON = jsonObject as? [String: Any] else {
                                DispatchQueue.main.async {
                                    completion(.failure(.noResponse))
                                }
                                return
                            }
                            if let error = responseJSON["error"] as? String {
                                DispatchQueue.main.async {
                                    completion(.failure(.webserviceError(error)))
                                }
                            } else {
                                DispatchQueue.main.async {
                                    completion(.success("Inmueble creado satisfactoriamente."))
                                }
                            }
                        }
                        task.resume()
                    }
                }
            }
        }
    }
    
    func uploadDocuments(files: [[String:String]], completion: @escaping (Result<[String],NetworkError>) -> Void) {
        let path = "files"
        let url = URL(string: baseURL + path)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        let json: [String: Any] = ["files": files]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        request.httpBody = jsonData
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    completion(.failure(.noData(error!.localizedDescription)))
                }
                return
            }
            let jsonObject = try? JSONSerialization.jsonObject(with: data, options: [])
            guard let responseJSON = jsonObject as? [String: Any] else {
                DispatchQueue.main.async {
                    completion(.failure(.noResponse))
                }
                return
            }
            guard let fileURL = responseJSON["file_urls"] as? [String] else {
                DispatchQueue.main.async {
                    completion(.failure(.noResponse))
                }
                return
            }
            DispatchQueue.main.async {
                completion(.success(fileURL))
            }
        }
        task.resume()
    }
    
    func sendAlert(token: String, images: [[String:String]], id: Int, name: String, description: String, completion: @escaping (Result<String,NetworkError>) -> Void) {
        NetworkManager.shared.uploadDocuments(files: images) { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let imageURLs):
                let path = "alert"
                let url = URL(string: self.baseURL + path)!
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
                let json: [String: Any]  = [
                    "token": token,
                    "name": name,
                    "description": description,
                    "inmueble_id": id,
                    "images": imageURLs
                ]
                let jsonData = try? JSONSerialization.data(withJSONObject: json)
                request.httpBody = jsonData
                let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                    guard let data = data, error == nil else {
                        DispatchQueue.main.async {
                            completion(.failure(.noData(error!.localizedDescription)))
                        }
                        return
                    }
                    let jsonObject = try? JSONSerialization.jsonObject(with: data, options: [])
                    guard let responseJSON = jsonObject as? [String: Any] else {
                        DispatchQueue.main.async {
                            completion(.failure(.noResponse))
                        }
                        return
                    }
                    if let error = responseJSON["error"] as? String {
                        DispatchQueue.main.async {
                            completion(.failure(.webserviceError(error)))
                        }
                    } else {
                        DispatchQueue.main.async {
                            completion(.success("Alerta enviada con éxito"))
                        }
                    }
                }
                task.resume()
            }
        }
    }
    
    func getNumberOfContributions(token: String, completion: @escaping (Result<[[Int]],NetworkError>) -> Void) {
        let path = "user/\(token)"
        let url = URL(string: baseURL + path)!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(.noData(error!.localizedDescription)))
                return
            }
            let jsonObject = try? JSONSerialization.jsonObject(with: data, options: [])
            guard let responseJSON = jsonObject as? [String: Any] else {
                DispatchQueue.main.async {
                    completion(.failure(.noResponse))
                }
                return
            }
            guard let alerts = responseJSON["alerts"] as? [Int], let applications = responseJSON["edition_requests"] as? [Int], let acceptedAlerts = responseJSON["accepted_edition_requests"] as? [Int] else {
                DispatchQueue.main.async {
                    completion(.failure(.noResponse))
                }
                return
            }
            DispatchQueue.main.async {
                completion(.success([alerts,applications,acceptedAlerts]))
            }
            
        }
        task.resume()
    }
    
    func getAlerts(token: String, completion: @escaping (Result<[Alert],NetworkError>) -> Void) {
        let path = "alerts/\(token)"
        let url = URL(string: baseURL + path)!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(.noData(error!.localizedDescription)))
                return
            }
            guard let alerts = try? JSONDecoder().decode([Alert].self, from: data) else {
                DispatchQueue.main.async {
                    completion(.failure(.webserviceError("Error al convertir JSON")))
                }
                return
            }
            DispatchQueue.main.async {
                completion(.success(alerts))
            }
            
        }
        task.resume()
    }
    
    func updatePassword(token: String, currentPassword: String, newPassword: String, completion: @escaping (Result<String,NetworkError>) -> Void) {
        let path = "\(token)/password"
        let url = URL(string: baseURL + path)!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        let json: [String: Any]  = [
            "token": token,
            "password": currentPassword,
            "new_password": newPassword
        ]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        request.httpBody = jsonData
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(.noData(error!.localizedDescription)))
                return
            }
            let jsonObject = try? JSONSerialization.jsonObject(with: data, options: [])
            guard let responseJSON = jsonObject as? [String: Any] else {
                DispatchQueue.main.async {
                    completion(.failure(.noResponse))
                }
                return
            }
            if let error = responseJSON["error"] as? String {
                DispatchQueue.main.async {
                    completion(.failure(.webserviceError(error)))
                }
            } else {
                DispatchQueue.main.async {
                    completion(.success((responseJSON["message"] as? String)!))
                }
            }
            
        }
        task.resume()
    }

    func updateUserInfo(uid: Int32, token: String, images: [[String:String]], name: String, completion: @escaping (Result<String,NetworkError>) -> Void) {
        
        NetworkManager.shared.uploadDocuments(files: images) { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let imageURLs):
                let path = "user"
                let url = URL(string: self.baseURL + path)!
                var request = URLRequest(url: url)
                request.httpMethod = "PUT"
                request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
                let json: [String: Any]  = [
                    "token": token,
                    "name": name,
                    "profile_pic_url": imageURLs[0]
                ]
                let jsonData = try? JSONSerialization.data(withJSONObject: json)
                request.httpBody = jsonData
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    guard let data = data, error == nil else {
                        completion(.failure(.noData(error!.localizedDescription)))
                        return
                    }
                    let jsonObject = try? JSONSerialization.jsonObject(with: data, options: [])
                    guard let responseJSON = jsonObject as? [String: Any] else {
                        DispatchQueue.main.async {
                            completion(.failure(.noResponse))
                        }
                        return
                    }
                    if let error = responseJSON["error"] as? String {
                        DispatchQueue.main.async {
                            completion(.failure(.webserviceError(error)))
                        }
                    } else {
                        guard let user = self.persistanceManager.fetchSingle(User.self, uid: uid) else {
                            DispatchQueue.main.async {
                                completion(.failure(.noTokenFound))
                            }
                            return
                        }
                        user.name = name
                        user.profilePicUrlRaw = imageURLs[0]
//                        let dateFormatterGet = DateFormatter()
//                        dateFormatterGet.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
//                        if let date = dateFormatterGet.date(from: dateCreatedRaw) {
//                            user.dateCreatedRaw = date
//                        } else {
//                            user.dateCreatedRaw = dateFormatterGet.date(from: "2001-01-01T01:48:07.883497")!
//                        }
//                        _ = self.persistanceManager.fetch(User.self).filter({ !$0.hasChanges }).forEach({ self.persistanceManager.delete($0) })
                        self.persistanceManager.save()
                        
                        DispatchQueue.main.async {
                            completion(.success(("Sus datos se actualizaron correctamente")))
                        }
                    }
                    
                }
                task.resume()
            }
        }
    }
    
    func sendIndependentAlert(token: String, latitude: Double,longitude: Double, address: String, images: [[String:String]], name: String, description: String, completion: @escaping (Result<String,NetworkError>) -> Void) {
        NetworkManager.shared.uploadDocuments(files: images) { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let imageURLs):
                let path = "alert"
                let url = URL(string: self.baseURL + path)!
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
                let json: [String: Any]  = [
                    "token": token,
                    "name": name,
                    "latitude": latitude,
                    "longitude": longitude,
                    "address": address,
                    "description": description,
                    "images": imageURLs
                ]
                let jsonData = try? JSONSerialization.data(withJSONObject: json)
                request.httpBody = jsonData
                let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                    guard let data = data, error == nil else {
                        DispatchQueue.main.async {
                            completion(.failure(.noData(error!.localizedDescription)))
                        }
                        return
                    }
                    let jsonObject = try? JSONSerialization.jsonObject(with: data, options: [])
                    guard let responseJSON = jsonObject as? [String: Any] else {
                        DispatchQueue.main.async {
                            completion(.failure(.noResponse))
                        }
                        return
                    }
                    if let error = responseJSON["error"] as? String {
                        DispatchQueue.main.async {
                            completion(.failure(.webserviceError(error)))
                        }
                    } else {
                        DispatchQueue.main.async {
                            completion(.success("Alerta enviada con éxito"))
                        }
                    }
                }
                task.resume()
            }
        }
    }
    
    func createChangeRequest(token:String, name: String, address: String, description: String, reason: String, id: Int, images: [[String:String]], documents: [[String:String]], completion: @escaping (Result<String, NetworkError>) -> Void) {
        
        NetworkManager.shared.uploadDocuments(files: images) { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let imageURLs):
                NetworkManager.shared.uploadDocuments(files: documents) { result in
                    switch result {
                    case .failure(let error):
                        completion(.failure(error))
                    case .success(let documentURLs):
                        let path = "edition_request"
                        let url = URL(string: self.baseURL + path)!
                        var request = URLRequest(url: url)
                        request.httpMethod = "POST"
                        request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
                        let json: [String: Any] = [
                            "token": token,
                            "name": name,
                            "address": address,
                            "description": description,
                            "reason": reason,
                            "inmueble_id": id,
                            "images": imageURLs,
                            "documents": documentURLs
                        ]
                        let jsonData = try? JSONSerialization.data(withJSONObject: json)
                        request.httpBody = jsonData
                        let task = URLSession.shared.dataTask(with: request) { data, response, error in
                            guard let data = data, error == nil else {
                                DispatchQueue.main.async {
                                    completion(.failure(.noData(error!.localizedDescription)))
                                }
                                return
                            }
                            let jsonObject = try? JSONSerialization.jsonObject(with: data, options: [])
                            guard let responseJSON = jsonObject as? [String: Any] else {
                                DispatchQueue.main.async {
                                    completion(.failure(.noResponse))
                                }
                                return
                            }
                            if let error = responseJSON["error"] as? String {
                                DispatchQueue.main.async {
                                    completion(.failure(.webserviceError(error)))
                                }
                            } else {
                                DispatchQueue.main.async {
                                    completion(.success("Solicitud enviada satisfactoriamente."))
                                }
                            }
                        }
                        task.resume()
                    }
                }
            }
        }
    }
    
}
