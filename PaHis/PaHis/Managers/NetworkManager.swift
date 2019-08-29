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
        let path = "login?email=\(email)&password=\(password)"
        let url = URL(string: baseURL + path)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
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
                                   "profile_pic_url": "xdxdxdxd",
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
                    guard let uid = responseJSON["id"] as? Int32, let name = responseJSON["name"] as? String, let email = responseJSON["email"] as? String, let profilePicUrlRaw = responseJSON["profile_pic_url"] as? String else {
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
    
    func getBuildings(forced: Bool, completion: @escaping (Result<([Category],[Building]),NetworkError>) -> Void) {
        let categories = persistanceManager.fetch(Category.self)
        if forced || categories.isEmpty {
            NetworkManager.shared.getCategories(){ result in
                switch result {
                case .failure(let error):
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                case .success(let categories):
                    let path = "inmuebles"
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
                        let jsonObject = try? JSONSerialization.jsonObject(with: data, options: [])
                        guard let responseJSON = jsonObject as? [[String: Any]] else {
                            DispatchQueue.main.async {
                                completion(.failure(.noResponse))
                            }
                            return
                        }
                        responseJSON.forEach({
                            var documents = [String]()
                            var images = [String]()
                            guard
                                let address = $0["address"] as? String,
                                let categoryID = $0["category"] as? Int,
                                let description = $0["description"] as? String,
                                let id = $0["id"] as? Int32,
                                let name = $0["name"] as? String,
                                let state = $0["state"] as? String else {
                                    DispatchQueue.main.async {
                                        completion(.failure(.noResponse))
                                    }
                                    return
                            }
                            let building = self.persistanceManager.fetchSingleOrCreate(Building.self, uid: id)
                            building.address = address
                            building.detail = description
                            building.name = name
                            building.state = state
                            if let documentsJson = $0["documents"] as? [[String:Any]], let imagesJson = $0["images"]  as? [[String:Any]] {
                                documents = documentsJson.map({ $0["url"] as! String })
                                images = imagesJson.map({ $0["url"] as! String })
                            }
                            guard let category = categories.filter({ $0.uid == categoryID }).first else {
                                completion(.failure(.categoryNoFound))
                                return
                            }
                            building.category = category
                            building.documents = documents
                            building.images = images
                            building.latitude = $0["latitude"] as? NSNumber
                            building.longitude = $0["longitude"] as? NSNumber
                        })
                        _ = self.persistanceManager.fetch(Building.self).filter({ !$0.hasChanges }).forEach({ self.persistanceManager.delete($0) })
                        self.persistanceManager.save()
                        let categories = self.persistanceManager.fetch(Category.self)
                        let buildings = self.persistanceManager.fetch(Building.self)
                        DispatchQueue.main.async {
                            completion(.success((categories, buildings)))
                        }
                    }
                    task.resume()
                }
            }
        } else {
            let buildings = persistanceManager.fetch(Building.self)
            completion(.success((categories, buildings)))
        }
    }
    
    func getCategories(completion: @escaping (Result<[Category],NetworkError>) -> Void) {
        let path = "categories"
        let url = URL(string: baseURL + path)!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(.noData(error!.localizedDescription)))
                return
            }
            let jsonObject = try? JSONSerialization.jsonObject(with: data, options: [])
            guard let responseJSON = jsonObject as? [[String: Any]] else {
                completion(.failure(.noResponse))
                return
            }
            responseJSON.forEach({
                guard let id = $0["id"] as? Int32 , let name = $0["name"] as? String else {
                    completion(.failure(.noResponse))
                    return
                }
                let category = self.persistanceManager.fetchSingleOrCreate(Category.self, uid: id)
                category.name = name
            })
            _ = self.persistanceManager.fetch(Category.self).filter({ !$0.hasChanges }).forEach({ self.persistanceManager.delete($0) })
            let categories = self.persistanceManager.fetch(Category.self)
            completion(.success(categories))
        }
        task.resume()
    }
}
