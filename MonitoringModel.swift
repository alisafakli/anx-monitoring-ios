//
//  Monitoring.swift
//  anx-monitoring-ios
//
//  Created by Ali SAFAKLI on 09.05.19.
//  Copyright © 2019 Anexia-IT. All rights reserved.
//

import Foundation

struct MonitoringModel: Codable {
    var runtime: Runtime
    var modules: Modules
    
    init(runtime: Runtime, modules: Modules) {
        self.runtime = runtime
        self.modules = modules
    }
}
