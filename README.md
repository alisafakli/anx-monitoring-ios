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

For sharing output file, add this notification observer in AppDelegate.swift 
```ruby
NotificationCenter.default.addObserver(self,selector: #selector(shareNotification),
                                    name: NSNotification.Name(rawValue: "ANXMonitoringIOS"),object: nil)
...
@objc func shareNotification(notification: NSNotification){
    if let dict = notification.userInfo as NSDictionary? {
        if let jsonData = dict["json"] as? Data {
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            let documentsDirectory = paths[0]
            let filename = "\(documentsDirectory)/ANXMonitoringIOSOutput.json"
            let fileURL = URL(fileURLWithPath: filename)
            do {
                try jsonData.write(to: fileURL, options: .atomic)
            } catch {
                print("Failed to write version monitoring json.")
            }
            let vc = UIActivityViewController(activityItems: [fileURL], applicationActivities: [])
            self.window?.rootViewController?.present(vc, animated: true, completion: nil)
        }       
    }
}
```
Final result should looks like below in AppDelegate.swift
```ruby
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions:      [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        NotificationCenter.default.addObserver(self,selector: #selector(shareNotification),
                                               name: NSNotification.Name(rawValue: "ANXMonitoringIOS"),object: nil)
        
        DispatchQueue.main.async {
            if let path = Bundle.main.path(forResource: "Frameworks", ofType: "plist"), let nsDictionary = NSDictionary(contentsOfFile: path) {
                let _ = Monitoring(nsDictionary, enableLog: true)
            }
        }
        return true
    }
    
    @objc func shareNotification(notification: NSNotification){
    if let dict = notification.userInfo as NSDictionary? {
        if let jsonData = dict["json"] as? Data {
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            let documentsDirectory = paths[0]
            let filename = "\(documentsDirectory)/ANXMonitoringIOSOutput.json"
            let fileURL = URL(fileURLWithPath: filename)
            do {
               try jsonData.write(to: fileURL, options: .atomic)
            } catch {
                print("Failed to write version monitoring json.")
            }
            let vc = UIActivityViewController(activityItems: [fileURL], applicationActivities: [])
            self.window?.rootViewController?.present(vc, animated: true, completion: nil)
        }
    }
}
```

Objective-C
```ruby
#import "AppDelegate.h"
@import ANXMonitoringIOS;
#import "ANXMonitoringIOS-Swift.h"

@interface AppDelegate ()
@end
@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(shareNotification:)
                                                 name:@"ANXMonitoringIOS"
                                               object:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString* path = [[NSBundle mainBundle] pathForResource:@"Frameworks" ofType:@"plist"];
        NSDictionary* dict = [NSDictionary dictionaryWithContentsOfFile:path];
        ObjCMonitoring *monitoring = [[ObjCMonitoring alloc] init:dict enableLog:YES];
    });
    return YES;
}
- (void) shareNotification:(NSNotification *) notification
{
    NSDictionary *userInfo = notification.userInfo;
    NSData *jsonData = [userInfo objectForKey:@"json"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0]stringByAppendingPathComponent:@"ANXMonitoringIOSOutput.json"];
    NSMutableArray *itemToShare = [[NSMutableArray alloc] init];
    [itemToShare addObject:filePath];
    if ([jsonData writeToFile:filePath atomically:YES]) {
        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:itemToShare applicationActivities:nil];
        activityVC.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll]; 
        UIViewController *topController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
        while (topController.presentedViewController) {
            topController = topController.presentedViewController;
        }
        [topController presentViewController:activityVC animated:YES completion:nil];
    }
}
```



*** Also check Build settings > Header Search Paths, and add "${PODS_ROOT}/" as recursive ***



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

