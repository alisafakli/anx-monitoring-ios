//
//  Modules.swift
//  anx-monitoring-ios
//
//  Created by Ali SAFAKLI on 09.05.19.
//  Copyright © 2019 Anexia-IT. All rights reserved.
//

import Foundation

struct Modules: Codable {
    var modules: [Module]
}

struct Module: Codable {
    var newest_version: String?
    var installed_version: String?
    var installed_version_licences: [String]?
    var name: String
    var newest_version_licences: [String]?
    
    init(newest_version: String,
        installed_version: String,
        installed_version_licences: [String],
        name: String,
        newest_version_licences: [String]) {
        self.newest_version = newest_version
        self.installed_version = installed_version
        self.installed_version_licences = installed_version_licences
        self.name = name
        self.newest_version_licences = newest_version_licences
    }
    
    init(name: String) {
        self.name = name
    }
    
    init (installed_version: String,
          installed_version_licences: [String],
          name: String) {
        self.installed_version = installed_version
        self.installed_version_licences = installed_version_licences
        self.name = name
    }
    
    init(newest_version:String, newest_version_licences: [String], name: String) {
        self.newest_version = newest_version
        self.newest_version_licences = newest_version_licences
        self.name = name
    }

}
