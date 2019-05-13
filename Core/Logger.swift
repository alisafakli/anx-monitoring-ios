//
//  Logger.swift
//  Pods
//
//  Created by Ali SAFAKLI on 13.05.19.
//

import Foundation


public class Logger {
    static var isMonitoringLogEnabled: Bool = true

    static func log(_ message : Any) {
        if isMonitoringLogEnabled {
            print(message)
        }
    }
}
