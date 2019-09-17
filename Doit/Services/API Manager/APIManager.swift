//
//  APIManager.swift
//  UsefulExtensions
//
//  Created by Артём Зиньков on 9/11/19.
//  Copyright © 2019 Artem Zinkov. All rights reserved.
//

import SwiftKeychainWrapper

typealias SuccessCompletion = ()->Void
typealias SuccessCompletionWithObject<T> = (T)->Void
typealias ErrorCompletion = (Error) -> Void

class APIManager {
 
    private static let keychainKey = "com.ArtemZinkov.Doit"
    private static var token: String? {
        set {
            if let newValue = newValue {
                KeychainWrapper.standard.set(newValue, forKey: keychainKey)
            } else {
                KeychainWrapper.standard.removeObject(forKey: keychainKey)
            }
        }
        
        get {
            return KeychainWrapper.standard.string(forKey: keychainKey)
        }
    }
    
    public static var hasToken: Bool { return token != nil }
    public static var shared: APIManager = APIManager()
    
    private let baseURL = URL(string: "https://testapi.doitserver.in.ua/api")!
    private let baseTaskURL = URL(string: "https://testapi.doitserver.in.ua/api/tasks")!
    private let parsingError: Error = NSError(domain: "Couldn't present ", code: 0, userInfo: nil)
    
    static func reset() {
        token = nil
    }
    
    public func getTasks(with parameters: [String: String],
                         _ successCompletion: SuccessCompletionWithObject<TaskListModel>? = nil,
                         _ errorCompetion: ErrorCompletion? = nil) {
        perform(.GET, to: baseTaskURL, with: parameters, TaskListModel.self, successCompletion, errorCompetion)
    }
    
    public func delete(_ task: TaskModel, _ success: SuccessCompletion? = nil, _ error: ErrorCompletion? = nil) {
        var parameters = task.mapToJSON()
        perform(.DELETE, to: baseTaskURL.appendingPathComponent(parameters.removeValue(forKey: "id")!), with: parameters, [String].self, { _ in success?() }, error)
    }
    
    public func save(_ task: TaskModel, _ success: SuccessCompletion? = nil, _ error: ErrorCompletion? = nil) {
        var parameters = task.mapToJSON()
        perform(.PUT, to: baseTaskURL.appendingPathComponent(parameters.removeValue(forKey: "id")!), with: parameters, [String].self, { _ in success?() }, error)
    }
    
    public func createTask(with parameters: [String: String], _ success: SuccessCompletion? = nil, _ error: ErrorCompletion? = nil) {
        perform(.POST, to: baseTaskURL, with: parameters, Bool.self, { _ in success?() }, error)
    }

    public func login(with credentials: Credentials, _ success: SuccessCompletion? = nil, _ error: ErrorCompletion? = nil) {
        authenticate(isRegister: false, credentials.mapToJSON() as? [String: String], nil, success, error)
    }
    
    public func register(with credentials: Credentials, _ success: SuccessCompletion? = nil, _ error: ErrorCompletion? = nil) {
        authenticate(isRegister: true, credentials.mapToJSON() as? [String: String], nil, success, error)
    }
    
    // MARK: - Private Methods
    private func authenticate(isRegister: Bool,
                              _ parameters: [String: String]? = nil,
                              _ headers: [String: String]? = nil,
                              _ success: SuccessCompletion? = nil,
                              _ error: ErrorCompletion? = nil) {
        
        let path = isRegister ? "users" : "auth"
        let url = baseURL.appendingPathComponent(path)
        
        perform(.POST, to: url, with: parameters, and: headers, [String: String].self, { token in
            APIManager.token = token["token"]
            success?()
        }, error)
    }
}





// A 'Don't Touch' Zone. As planned - next code shouldn't be edited at all in future

// MARK: - GET
private extension APIManager {
    
    enum RequestTypes: String {
        case GET = "GET"
        case POST = "POST"
        case DELETE = "DELETE"
        case PUT = "PUT"
    }
    
    func perform<T: Decodable>(_ requestType: RequestTypes,
                               to url: URL,
                               with parameters: [String: String]? = nil,
                               and headers: [String: String]? = nil,
                               _ aDecodable: T.Type,
                               _ successCompletion: ((T) -> Void)? = nil,
                               _ errorCompletion: ((Error) -> Void)? = nil) {
        var mutableUrl = url
        if var urlComponents = URLComponents(url: mutableUrl, resolvingAgainstBaseURL: true), parameters != nil {
            urlComponents.queryItems = []
            parameters?.forEach { urlComponents.queryItems?.append(URLQueryItem(name: $0.key, value: $0.value)) }
            mutableUrl = urlComponents.url ?? url
        }
        
        var urlRequest = URLRequest(url: mutableUrl)
        urlRequest.httpMethod = requestType.rawValue
        urlRequest.allHTTPHeaderFields = headers
        
        if let token = APIManager.token {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    errorCompletion?(error)
                }
                return
            } else if let httpResponse = response as? HTTPURLResponse,
                !(200...399).contains(httpResponse.statusCode),
                let data = data {
                
                let errorMessage = String(data: data, encoding: .utf8) ?? ""
                DispatchQueue.main.async {
                    errorCompletion?(NSError(domain: errorMessage,
                                             code: httpResponse.statusCode,
                                             userInfo: httpResponse.allHeaderFields as? [String: Any]))
                }
                return
            } else if let data = data {
                do {
                    
                    let decoder = JSONDecoder()
                    let decodedObject = try decoder.decode(aDecodable.self, from: data)
                    
                    DispatchQueue.main.async {
                        successCompletion?(decodedObject)
                    }
                    return
                } catch let error {
                    DispatchQueue.main.async {
                        errorCompletion?(error)
                    }
                    return
                }
            }
            
            DispatchQueue.main.async {
                errorCompletion?(NSError(domain: "Unknown Error", code: 0, userInfo: nil))
            }
        }.resume()
    }
}
