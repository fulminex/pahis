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
    
    var errorDescription: String {
        switch self {
        case .noData(let error): return "Error al conectar con el servidor. \(error)"
        case .noResponse: return "Error en la respuesta del servidor."
        case .noTokenFound: return "Error al generar el token de sesión."
        case .noUserTypeFound: return "Error al obtener el tipo de usuario."
        case .webserviceError(let error): return error
        }
    }
    
}

class NetworkManager {
    
    private init () {}
    static let shared = NetworkManager()
    let baseURL = "https://pahis-desafio-uno.herokuapp.com/api/"
    
    func login(email: String, password: String, completion: @escaping (Result<String,NetworkError>) -> Void) {
        let path = "login?email=\(email)&password=\(password)"
        let url = URL(string: baseURL + path)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
                completion(.failure(.noData(error!.localizedDescription)))
                return
            }
            let jsonObject = try? JSONSerialization.jsonObject(with: data, options: [])
            guard let responseJSON = jsonObject as? [String: Any] else {
                completion(.failure(.noResponse))
                return
            }
            if let error = responseJSON["error"] as? String {
                completion(.failure(.webserviceError(error)))
            } else {
                guard let token = responseJSON["token"] as? String else {
                    completion(.failure(.noTokenFound))
                    return
                }
                completion(.success(token))
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
                completion(.failure(.noData(error!.localizedDescription)))
                return
            }
            let jsonObject = try? JSONSerialization.jsonObject(with: data, options: [])
            guard let responseJSON = jsonObject as? [String: Any] else {
                completion(.failure(.noResponse))
                return
            }
            if let error = responseJSON["error"] as? String {
                completion(.failure(.webserviceError(error)))
            } else {
                completion(.success("Usuario creado satisfactoriamente."))
            }
        }
        task.resume()
    }
    
    func getUserType(token: String, completion: @escaping (Result<String,NetworkError>) -> Void) {
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
                completion(.failure(.noResponse))
                return
            }
            if let error = responseJSON["error"] as? String {
                completion(.failure(.webserviceError(error)))
            } else {
                guard let userTypeName = responseJSON["user_type"] as? String else {
                    completion(.failure(.noUserTypeFound))
                    return
                }
                DispatchQueue.main.async {
                    completion(.success(userTypeName))
                }
            }
        }
        task.resume()
    }
    
    func logout(token: String, completion: @escaping (Result<String,NetworkError>) -> Void) {
        let path = "logout?token=\(token)"
        let url = URL(string: baseURL + path)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(.noData(error!.localizedDescription)))
                return
            }
            let jsonObject = try? JSONSerialization.jsonObject(with: data, options: [])
            guard let responseJSON = jsonObject as? [String: Any] else {
                completion(.failure(.noResponse))
                return
            }
            if let error = responseJSON["error"] as? String {
                completion(.failure(.webserviceError(error)))
            } else {
                guard let message = responseJSON["message"] as? String else {
                    completion(.failure(.noResponse))
                    return
                }
                completion(.success(message))
            }
        }
        task.resume()
    }
}
