//
//  NetworkLogger.swift
//  anx-monitoring-ios
//
//  Created by Ali SAFAKLI on 08.05.19.
//  Copyright © 2019 Anexia-IT. All rights reserved.
//

import Foundation

class NetworkLogger {
    static func log(request: URLRequest) {
        print(request)
    }
    
    static func log(response: URLResponse) {}
}
