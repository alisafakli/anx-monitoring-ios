# ANXMonitoringIOS
Anexia Monitoring IOS Framework, collects version and licese information for all installed pods and send the Anexia's API to check if update is available.

[![Version](https://img.shields.io/cocoapods/v/ANXMonitoringIOS.svg?style=flat)](https://cocoapods.org/pods/ANXMonitoringIOS)
[![License](https://img.shields.io/cocoapods/l/ANXMonitoringIOS.svg?style=flat)](https://cocoapods.org/pods/ANXMonitoringIOS)
[![Platform](https://img.shields.io/cocoapods/p/ANXMonitoringIOS.svg?style=flat)](https://cocoapods.org/pods/ANXMonitoringIOS)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements
* As a first step create a Propert List (.plist) file. For example 'Frameworks.plist'.
* Check your Pods in Pod file and copy the name of your first pod. 
* Paste this name as a key area of the plist.
* Find this pod in https://cocoapods.org/
Eg. https://cocoapods.org/pods/ANXMonitoringIOS
* Right click "See Podspec" button and press "Copy Link Address"
* Come back your 'Frameworks.plist' file and paste the link as a value.


| Key  | Type | Value |
| ------------- | ------------- | ------------- |
| ▼Root | Dictionary |  (1 value)
| ANXMonitoringIOS  | String | https://github.com/CocoaPods/Specs/blob/master/Specs/3/4/b/ANXMonitoringIOS/1.0.3/ANXMonitoringIOS.podspec.json  |

* Repeat this process for all pods.


## Installation



ANXMonitoringIOS is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'ANXMonitoringIOS'
```
## Usage
Swift
```ruby
import ANXMonitoringIOS
...
DispatchQueue.main.async {
    if let path = Bundle.main.path(forResource: "Frameworks", ofType: "plist"), 
        let nsDictionary = NSDictionary(contentsOfFile: path) {
        //If you want to see the log use enableLog: true, if not use enableLog: false
        let _ = Monitoring(nsDictionary, enableLog: true)
    }
}
```
Objective-C


## Author

Ali Safakli, Mobile Developer

## License

The MIT License (MIT)

Copyright (c) 2019 ANEXIA Internetdienstleistungs GmbH

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

