//
//  Monitoring.swift
//  anx-monitoring-ios
//
//  Created by Ali SAFAKLI on 08.05.19.
//  Copyright © 2019 Anexia-IT. All rights reserved.
//

import Foundation

@objc public class ObjCMonitoring: NSObject {
    
    @objc public init(enableLog: Bool) {
        super.init()
        let _ = Monitoring(enableLog: enableLog)
    }
    
    @objc public init(_ frameworkApiDictionary: NSDictionary, enableLog: Bool) {
        super.init()
        let _ = Monitoring(frameworkApiDictionary, enableLog: enableLog)
    }
}

public class Monitoring {
    
    let frameworkApiDictionary:NSDictionary!
    
    /**
     First Initializer
     
     - Class: Monitoring
     - Parameter: enableLog: Enable / Disable Log
     
     - Remark:
     Framework .plist file not exist as input in this initializer
     Default: Try to find Frameworks.plist automatically
     
     - SeeAlso:  `public init(_ frameworkApiDictionary: NSDictionary, enableLog: Bool)`
     
     - Precondition: `enableLog` should not be nil.
     */
    public init(enableLog: Bool) {
        Logger.isMonitoringLogEnabled = enableLog
        var nsDictionary: NSDictionary!
        if let path = Bundle.main.path(forResource: Constants.DEFAULT_FRAMEWORK_PLIST, ofType: "plist") {
            nsDictionary = NSDictionary(contentsOfFile: path)
            self.frameworkApiDictionary = nsDictionary
        } else {
            self.frameworkApiDictionary = NSDictionary()
        }
        collectData()
    }
    
    /**
     Second Initializer
     
     - Class: Monitoring
     - Parameter: 'frameworkApiDictionary' dictionary object filled with .plist key and values
     - Parameter: enableLog: Enable / Disable Log
     
     - Remark:
     Custom .plist file's data is exist as dictionary in this initializer
     
     - SeeAlso:  `public init(enableLog: Bool)`
     
     - Precondition: `frameworkApiDictionary` and  `enableLog` should not be nil.
     */
    public init(_ frameworkApiDictionary: NSDictionary, enableLog: Bool) {
        Logger.isMonitoringLogEnabled = enableLog
        self.frameworkApiDictionary = frameworkApiDictionary
        collectData()
    }
    
    /**
     Starts to collect data from API
     
     - Class: Monitoring
     
     - Remark:
     This function send request to collect all versions for each key value in dictionary and determine which one has a newer version.
     
     */
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
                                Logger.log("\(tuple.name) (\(version)) is up to date")

                            } else {
                                Logger.log("\(tuple.name) (\(version)) has newer version: \(newVersion)")
                                newVersionAvailableDict["\(tuple.name)"] = newVersion
                            }
                            
                        }
                    }
                    downloadGroup.leave()
                }
                
            }
        }
        downloadGroup.notify(queue: DispatchQueue.main) {
            Logger.log(newVersionAvailableDict)
            self.getLicenses(newVersionAvailableDict: newVersionAvailableDict, frameworkVersionDict: frameworkVersionDict)
        }
    }
    
    /**
     Collect all license data from raw json
     
     - Class: Monitoring
     - Parameter: 'newVersionAvailableDict' values which has newer version
     - Parameter: 'frameworkVersionDict' existing versions
     
     - Remark:
    This function sends multiple async request so we have 2 request DispatchGroup and for the determine all finished we are using third DispatchGroup 'groupFinal'

     */
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
            Logger.log(dataDict)
        }
        
        //All data collected
        groupFinal.notify(queue: DispatchQueue.main) {
            Logger.log("Data is ready!")
            let moduleArray = self.getModules(newVersionAvailableDict: newVersionAvailableDict, dict: dataDict)
            
            let modules = Modules(modules: moduleArray)
            let runtime = self.getRuntimeData(modules: modules)
            
            let monitoringModel = MonitoringModel(runtime: runtime, modules: modules)
//            networkManager.sendMonitoringData(monitoringModel: monitoringModel, success: {
//                print("Monitoring Data Successfully Sent.")
//            }, failure: { (error) in
//                print(error)
//            })
            //TODO: Will be Deleted after API implementation
            if let jsonData = try? JSONEncoder().encode(monitoringModel) {
                Logger.log(jsonData.prettyPrintedJSONString as Any)
            }
        }
    }
    
    /**
     Find the newest version for ANXMonitoringIOS framework
     
     - Class: Monitoring
     - Parameter: modules: Modules
     
     */
    private func getNewestVersionOfMonitoringFramework(modules: Modules) -> String? {
        if let newVersion = modules.modules.filter({$0.name == "ANXMonitoringIOS"}).first?.newest_version    {
            return newVersion
        }
        return nil
    }
    
    /**
     Prepare Runtime object's data here
     
     - Class: Monitoring
     - Parameter: modules: Modules
     
     */
    private func getRuntimeData(modules: Modules) -> Runtime {
        let platform_version = UIDevice.current.model + ", version: " + UIDevice.current.systemVersion + ", deviceId: " + UIDevice.current.identifierForVendor!.uuidString + " " + "(\(Date()))"
        let platform = UIDevice.current.systemName
        let installedVersion = getInstalledFrameworksWithVersionNumber()["ANXMonitoringIOS"]
        let newVersion = getNewestVersionOfMonitoringFramework(modules: modules)
        //TODO: Get the newest version for framework
        return Runtime(platform_version: platform_version ,
                       platform: platform,
                       framework_installed_version: installedVersion ?? "",
                       framework_newest_version: newVersion ?? (installedVersion ?? ""),
                       framework: Constants.IOS_FRAMEWORK)
    }
    
    /**
     Prepare Module array for Modules object's data here
     
     - Class: Monitoring
     - Parameter: newVersionAvailableDict: [String:String] - Only has new versions
     - Parameter: dict: [String:String] - All data

     */
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
    
    /**
     Determine newest version here
     
     - Class: Monitoring
     - Parameter: currentVersion: String - installed version
     - Parameter: availableVersions: [String] - All available versions
     
     
     */
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
    
    /**
     Do string operationz s for preparing correct url to collect data
     
     - Class: Monitoring
     - Parameter: name: String - framework name
     - Return: (address:String, name:String)? tuple
     
     
     */
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
    
    /**
     Prepare dictionary for installed frameworks with version
     
     - Class: Monitoring
     - Return: [String:String] dictionary
     
     
     */
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


