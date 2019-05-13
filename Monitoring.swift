//
//  Monitoring.swift
//  anx-monitoring-ios
//
//  Created by Ali SAFAKLI on 08.05.19.
//  Copyright © 2019 Anexia-IT. All rights reserved.
//

import Foundation

public class Monitoring {
    
    let frameworkApiDictionary:NSDictionary!
    
    public init() {
        var nsDictionary: NSDictionary!
        if let path = Bundle.main.path(forResource: Constants.DEFAULT_FRAMEWORK_PLIST, ofType: "plist") {
            nsDictionary = NSDictionary(contentsOfFile: path)
            self.frameworkApiDictionary = nsDictionary
        } else {
            self.frameworkApiDictionary = NSDictionary()
        }
        collectData()
    }
    
    public init(_ frameworkApiDictionary: NSDictionary) {
        self.frameworkApiDictionary = frameworkApiDictionary
        collectData()
    }
    
    private func collectData() {
        let frameworkVersionDict = getInstalledFrameworksWithVersionNumber()
        let networkManager = NetworkManager()
        let downloadGroup = DispatchGroup()
        
        var newVersionAvailableDict: [String:String] = [:]
        for (name,version) in frameworkVersionDict {
            if let tuple = getRepositoryInfoFromFrameworkName(name: name) {
                downloadGroup.enter()
                networkManager.getAllSpecInfoFor(repo: "\(tuple.address)\(tuple.name)") { (data, string) in
                    if let versionArray = data {
                        if let newVersion = self.getNewVersion(currentVersion: name, availableVersions: versionArray) {
                            if newVersion == version {
                                print("\(tuple.name) (\(version)) is up to date")

                            } else {
                                print("\(tuple.name) (\(version)) has newer version: \(newVersion)")
                                newVersionAvailableDict["\(tuple.name)"] = newVersion
                            }
                            
                        }
                    }
                    downloadGroup.leave()
                }
                
            }
        }
        downloadGroup.notify(queue: DispatchQueue.main) {
            print(newVersionAvailableDict)
            self.getLicenses(newVersionAvailableDict: newVersionAvailableDict, frameworkVersionDict: frameworkVersionDict)
        }
    }
    
    private func getLicenses(newVersionAvailableDict: [String:String], frameworkVersionDict: [String:String]) {
        let group1 = DispatchGroup()
        let group2 = DispatchGroup()
        let groupFinal = DispatchGroup()
        groupFinal.enter()
        groupFinal.enter()
        let networkManager = NetworkManager()
        networkManager.changeEnvironment(.rawJSONApi)
        var dataDict: [String:String] = [:]
        
        
        //Get current licenses
        for (name,version) in frameworkVersionDict {
            if let tuple = getRepositoryInfoFromFrameworkName(name: name) {
                group1.enter()
                networkManager.getRawJSONFor(tuple: tuple, id: version, completion: { (license, error) in
                    if let license = license {
                        dataDict["\(tuple.name)\(Constants.KEY_SEPERATOR)\(version)"] = license
                    }
                    group1.leave()
                })
            }
        }

        group1.notify(queue: DispatchQueue.main) {
            groupFinal.leave()
            print(dataDict)

        }

        //New version licenses
        for (key, value) in newVersionAvailableDict {
            if let tuple = getRepositoryInfoFromFrameworkName(name: key) {
                group2.enter()
                networkManager.getRawJSONFor(tuple: tuple, id: value, completion: { (license, error) in
                    if let license = license {
                        dataDict["\(tuple.name)\(Constants.KEY_SEPERATOR)\(value)"] = license
                    }
                    group2.leave()
                })
            }
        }

        group2.notify(queue: DispatchQueue.main) {
            groupFinal.leave()
            print(dataDict)
        }
        
        //All data collected
        groupFinal.notify(queue: DispatchQueue.main) {
            print("Data is ready!")
            let moduleArray = self.getModules(newVersionAvailableDict: newVersionAvailableDict, dict: dataDict)
            let runtime = self.getRuntimeData()
            let modules = Modules(modules: moduleArray)
            
            let monitoringModel = MonitoringModel(runtime: runtime, modules: modules)
//            networkManager.sendMonitoringData(monitoringModel: monitoringModel, success: {
//                print("Monitoring Data Successfully Sent.")
//            }, failure: { (error) in
//                print(error)
//            })
            //TODO: Will be Deleted after API implementation
            if let jsonData = try? JSONEncoder().encode(monitoringModel) {
                print(jsonData.prettyPrintedJSONString as Any)
            }
        }
    }
    
    
    private func getRuntimeData() -> Runtime {
        let platform_version = UIDevice.current.model + ", version: " + UIDevice.current.systemVersion
        let platform = UIDevice.current.systemName
        let installedVersion = getInstalledFrameworksWithVersionNumber()["anx_monitoring_ios"]
        //TODO: Get the newest version for framework
        return Runtime(platform_version: platform_version ,
                       platform: platform,
                       framework_installed_version: installedVersion ?? "",
                       framework_newest_version: "",
                       framework: Constants.IOS_FRAMEWORK)
    }
    
    private func getModules(newVersionAvailableDict:[String:String], dict: [String:String]) -> [Module] {
        var moduleArray: [Module] = []
        for (key,license) in dict {
            let array = key.split(separator: Constants.KEY_SEPERATOR.first!)
            if let name = array.first, let version = array.last {
                // - Version is up to date
                if !newVersionAvailableDict.keys.contains(String(name)) {
                    let module = Module(newest_version: String(version), installed_version: String(version), installed_version_licences: [license], name: String(name), newest_version_licences: [license])
                    moduleArray.append(module)
                }
                // Has new version already added into array
                else if let index = moduleArray.firstIndex(where: {$0.name == name}) {
                    if let _ = moduleArray[index].installed_version {
                        moduleArray[index].newest_version = String(version)
                        moduleArray[index].newest_version_licences = [license]
                    } else {
                        moduleArray[index].installed_version = String(version)
                        moduleArray[index].installed_version_licences = [license]
                    }
                }
                // - Has new version not yet added into array
                else {
                    //Create the module and assign it current data
                    if String(version) == getInstalledFrameworksWithVersionNumber()[String(name)] {
                        let module = Module(installed_version: String(version), installed_version_licences: [license], name: String(name))
                        moduleArray.append(module)
                    }
                    //New version data
                    else {
                        let module = Module(newest_version: String(version), newest_version_licences:  [license], name: String(name))
                        moduleArray.append(module)
                    }
                }
            }
        }
        return moduleArray
    }
    
    private func getNewVersion(currentVersion: String, availableVersions: [String]) -> String? {
        var arrayOfStrings = availableVersions
        //Remove beta versions in the list
        arrayOfStrings = arrayOfStrings.filter({$0.contains(Constants.ENDPOINT_EXCLUDE_VERSION) == false})
        //Sort version array
        arrayOfStrings.sort { (a, b) -> Bool in
            a.localizedStandardCompare(b) == .orderedAscending
        }
        
        if let top = arrayOfStrings.last, top.compare(currentVersion, options: .numeric) == .orderedAscending {
            return top
        }
        
        return nil
    }
    
    private func getRepositoryInfoFromFrameworkName(name: String) -> (address:String, name:String)? {
        for (key, value) in self.frameworkApiDictionary {
            if let key = key as? String, key == name, let value = value as? String {
                if let firstPart = value.components(separatedBy: Constants.ENDPOINT_GITHUB_ADDRESS_SPLIT).last, let address = firstPart.components(separatedBy: name).first {
                    return (address,name)
                }
            }
        }
        return nil
    }
    
    private func getInstalledFrameworksWithVersionNumber() -> [String:String] {
        var frameworkVersionDict: [String:String] = [:]
        let frameworks = Bundle.allFrameworks.filter({
            ($0.bundleIdentifier?.contains(Constants.ENDPOINT_COCOAPODS_FRAMEWORK) == true) || ($0.bundleIdentifier?.contains("com.apple.") == false)
        })
        
        for framework in frameworks {
            if let bundleName = framework.infoDictionary?["CFBundleName"] as? String, let versionNumber = framework.infoDictionary?["CFBundleShortVersionString"] as? String {
                frameworkVersionDict[bundleName] = versionNumber
            }
        }
        return frameworkVersionDict
    }
    
}


