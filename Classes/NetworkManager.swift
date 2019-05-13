//
//  NetworkManager.swift
//  anx-monitoring-ios
//
//  Created by Ali SAFAKLI on 08.05.19.
//  Copyright © 2019 Anexia-IT. All rights reserved.
//

import Foundation

enum NetworkResponse:String {
    case success
    case authenticationError = "You need to be authenticated first."
    case badRequest = "Bad request"
    case outdated = "The url you requested is outdated."
    case failed = "Network request failed."
    case noData = "Response returned with no data to decode."
    case unableToDecode = "We could not decode the response."
}

enum Result<String>{
    case success
    case failure(String)
}

enum NetworkEnvironment {
    case defaultApi
    case rawJSONApi
    case anexiaAPI
}

struct NetworkManager {
    static var environment : NetworkEnvironment = .defaultApi
    static let MovieAPIKey = ""
    let router = Router<GithubAPI>()
    
    func changeEnvironment(_ new: NetworkEnvironment) {
        NetworkManager.environment = new
    }
    
    func getAllSpecInfoFor(repo:String, completion: @escaping (_ data: [String]?,_ error: String?)->()){
        router.request(.allSpecInfo(repo: repo)) { data, response, error in
        
            if error != nil {
                completion(nil, "Please check your network connection.")
            }
            
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    do {
                        var finalArray:[String] = []
                        if let array = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers) as? [Any] {
                            for dict in array {
                                if let dict = dict as? [String: Any], let version = dict["name"] as? String {
                                    finalArray.append(version)
                                }
                            }
                        }
                        
                        completion(finalArray,nil)
                    }catch {
                        Logger.log(error)
                        completion(nil, NetworkResponse.unableToDecode.rawValue)
                    }
                case .failure(let networkFailureError):
                    completion(nil, networkFailureError)
                }
            }
        }
    }
    
    
    func getRawJSONFor(tuple:(address:String,name:String),id: String, completion: @escaping (_ data: String?,_ error: String?)->()){
        router.request(.specJSONById(address:tuple.address, name: tuple.name, id: id)) { data, response, error in
            
            if error != nil {
                completion(nil, "Please check your network connection.")
            }
            
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    do {
                        if let dict = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers) as? [String: Any] {
                            if let license = dict["license"] as? [String:String], let text = license["text"] {
                                completion(text,nil)
                            } else if let license = dict["license"] as? String {
                                completion(license,nil)
                            }
                        }
                        
                        
                    }catch {
                        Logger.log(error)
                        completion(nil, NetworkResponse.unableToDecode.rawValue)
                    }
                case .failure(let networkFailureError):
                    completion(nil, networkFailureError)
                }
            }
        }
    }
    
    func sendMonitoringData(monitoringModel: MonitoringModel, success: @escaping ()->(), failure: @escaping (_ error: String)->()) {
        let jsonEncoder = JSONEncoder()
        //Create json data to post it
        guard let jsonData = try? jsonEncoder.encode(monitoringModel) else {
            return failure("JSON format is invalid!")
        }
        Logger.log(jsonData.prettyPrintedJSONString as Any)
        let token = ""
        router.request(.sendMonitoringDataToAPI(accessToken: token), jsonData) { (data, response, error) in
            if error != nil {
                failure("Please check your network connection.")
            }
            
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                   success()
        
                case .failure(let networkFailureError):
                    failure(networkFailureError)
                }
            }
        }
    }
    
    
    fileprivate func handleNetworkResponse(_ response: HTTPURLResponse) -> Result<String>{
        switch response.statusCode {
        case 200...299: return .success
        case 401...500: return .failure(NetworkResponse.authenticationError.rawValue)
        case 501...599: return .failure(NetworkResponse.badRequest.rawValue)
        case 600: return .failure(NetworkResponse.outdated.rawValue)
        default: return .failure(NetworkResponse.failed.rawValue)
        }
    }
}
