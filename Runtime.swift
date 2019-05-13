//
//  License.swift
//  anx-monitoring-ios
//
//  Created by Ali SAFAKLI on 08.05.19.
//  Copyright © 2019 Anexia-IT. All rights reserved.
//

import Foundation

struct Runtime: Codable {
    var platform_version: String
    var platform: String
    var framework_installed_version: String
    var framework_newest_version: String
    var framework: String
    
    init(platform_version: String,
         platform: String,
         framework_installed_version: String,
         framework_newest_version: String,
         framework: String) {
        
        self.platform_version = platform_version
        self.platform = platform
        self.framework_installed_version = framework_installed_version
        self.framework_newest_version = framework_newest_version
        self.framework = framework

    }
    
}

