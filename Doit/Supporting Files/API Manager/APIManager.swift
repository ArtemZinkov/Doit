//
//  APIManager.swift
//  UsefulExtensions
//
//  Created by Артём Зиньков on 9/11/19.
//  Copyright © 2019 Artem Zinkov. All rights reserved.
//

import Foundation

typealias GetSuccessCompletion<T> = (T)->Void
typealias ErrorCompletion = (Error) -> Void
typealias PostSuccessCompletion = ()->Void

class APIManager {
    private static var token: String? { return "" } // TODO: Keychain
    public static var shared: APIManager = APIManager()
    private let baseURL = URL(string: "http://testapi.doitserver.in.ua/public/api")!
    
    public func getTasks(_ successCompletion: GetSuccessCompletion<TaskListModel>? = nil,
                         _ errorCompetion: ErrorCompletion? = nil) {
        
        get(from: baseURL.appendingPathComponent("tasks"), TaskListModel.self, successCompletion, errorCompetion)
    }
    
    // Authentification
    public func login(with credentials: Credentials, success: PostSuccessCompletion? = nil, error: ErrorCompletion? = nil) {
        post(to: baseURL.appendingPathComponent("auth"), success, error)
    }
    
    public func register(with credentials: Credentials, success: PostSuccessCompletion? = nil, error: ErrorCompletion? = nil) {
        post(to: baseURL.appendingPathComponent("users"), success, error)
    }
}

struct Credentials {
    let email: String
    let password: String
}




// A 'Don't Touch' Zone. As planned - next code shouldn't be edited at all in future

// MARK: - GET
private extension APIManager {
    
    func get<T: Decodable>(from url: URL,
                           with parameters: [String: String]? = nil,
                           _ aDecodable: T.Type,
                           _ successCompletion: ((T) -> Void)? = nil,
                           _ errorCompletion: ((Error) -> Void)? = nil) {
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        parameters?.forEach { urlRequest.addValue($0.key, forHTTPHeaderField: $0.value) }
        
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                errorCompletion?(error)
                return
            } else if let httpResponse = response as? HTTPURLResponse,
                !(200...399).contains(httpResponse.statusCode) {
                errorCompletion?(NSError(domain: httpResponse.debugDescription,
                                        code: 0,
                                        userInfo: httpResponse.allHeaderFields as? [String: Any]))
                return
            } else if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let decodedObject = try decoder.decode(aDecodable.self, from: data)
                    
                    successCompletion?(decodedObject)
                } catch let error {
                    errorCompletion?(error)
                }
                
                return
            }
            
            errorCompletion?(NSError(domain: "Unknown Error", code: 0, userInfo: nil))
        }.resume()
    }
}

// MARK: - POST
private extension APIManager {
    
    func post(to url: URL,
              _ successCompletion: (() -> Void)? = nil,
              _ errorCompletion: ((Error) -> Void)? = nil) {
        
        
    }
}

// MARK: - PUT
private extension APIManager {
    
    func put<T: Encodable>(to url: URL,
                           _ anEncodable: T.Type,
                           _ successCompletion: (() -> Void)? = nil,
                           _ errorCompletion: ((Error) -> Void)? = nil) {
        
        
    }
}

// MARK: - DELETE
private extension APIManager {
    
    func delete(_ url: URL,
                with parameters: [String: String]? = nil,
                _ successCompletion: (() -> Void)? = nil,
                _ errorCompletion: ((Error) -> Void)? = nil) {
        
        
    }
}
