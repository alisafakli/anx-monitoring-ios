//
//  GithubAPI.swift
//  anx-monitoring-ios
//
//  Created by Ali SAFAKLI on 08.05.19.
//  Copyright © 2019 Anexia-IT. All rights reserved.
//

import Foundation

public enum GithubAPI {
    case allSpecInfo(repo: String)
    case specInfoById(repo:String,id:String)
    case specJSONById(address:String,name:String,id:String)
    case sendMonitoringDataToAPI(accessToken:String)

}


extension GithubAPI: EndPointType {
    
    var environmentBaseURL : String {
        switch self {
        case .allSpecInfo(_):
            return "https://api.github.com/repos/CocoaPods/Specs/contents/Specs/"
        case .specInfoById(_):
            return "https://api.github.com/repos/CocoaPods/Specs/contents/Specs/"
        case .specJSONById(_):
            return "https://raw.githubusercontent.com/CocoaPods/Specs/master/Specs/"
        case .sendMonitoringDataToAPI(_):
            return "https://yourapp.tld/anxapi/v1/modules/"
        }
    }
    
    var baseURL: URL {
        guard let url = URL(string: environmentBaseURL) else { fatalError("baseURL could not be configured.")}
        return url
    }
    
    var path: String {
        switch self {
        case .allSpecInfo(let repo):
            return "\(repo)"
        case .specJSONById(let address, let name, let id):
            return "\(address)\(name)/\(id)/\(name).podspec.json"
        case .specInfoById(let repo, let id):
            return "\(repo)/\(id)"
        case .sendMonitoringDataToAPI( _):
            return ""
        }

    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .allSpecInfo(_):
            return .get
        case .specInfoById(_):
            return .get
        case .specJSONById(_):
            return .get
        case .sendMonitoringDataToAPI(_):
            return .post
        }
    }
    
    var task: HTTPTask {
        switch self {
        case .allSpecInfo(_ ):
            return .requestParameters(bodyParameters: nil,
                                      bodyEncoding: .urlEncoding,
                                  urlParameters: ["ref":"master"])
        case .specJSONById(_, _, _):
            return .requestParameters(bodyParameters: nil, bodyEncoding: .urlEncoding, urlParameters: nil)
        case .specInfoById(_, _):
            return .requestParameters(bodyParameters: nil,
                                      bodyEncoding: .urlEncoding,
                                      urlParameters: ["ref":"master"])
        case .sendMonitoringDataToAPI(let accessToken):
            return .requestParameters(bodyParameters: nil,
                                      bodyEncoding: .urlEncoding,
                                      urlParameters: ["access_token":accessToken])
        }
    }
    
    var headers: HTTPHeaders? {
        return nil
    }
}
