 //
//  AppDelegate.swift
//  Ripelist
//
//  Created by Aaron Williamson on 2/25/15.
//  Copyright (c) 2015 Aaron Williamson. All rights reserved.
//

import UIKit
import Parse
import ParseFacebookUtilsV4
import Apptentive
import Flurry_iOS_SDK
 
@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // White status bar
        application.setStatusBarStyle(.LightContent, animated: false)
        // Show welcome screen on first app launch
        switch NSUserDefaults.standardUserDefaults().objectForKey("hasLaunchedOnce") {
        case nil:
            self.setRootViewController(toViewController: "NoticeView")
        default:
            self.setRootViewController(toViewController: "HomeVC")
        }
        // Parse, Facebook, Flurry, Apptentive integration
        self.integrateThirdPartyServices(withLaunchOptions: launchOptions)
        
        if application.applicationState != .Background {
            
            // 2
            let preBackgroundPush = !application.respondsToSelector(Selector("backgroundRefreshStatus"))
            let oldPushHandlerOnly = !self.respondsToSelector(.didReceiveRemoteNotification)
            var pushPayload = false
            if let options = launchOptions {
                pushPayload = options[UIApplicationLaunchOptionsRemoteNotificationKey] != nil
            }
            if (preBackgroundPush || oldPushHandlerOnly || pushPayload) {
                PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
            }
        }
        
        // 3
        let types: UIUserNotificationType = [.Alert, .Badge, .Sound]
        let settings = UIUserNotificationSettings(forTypes: types, categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        
        // Return from the Facebook SDK
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    // Facebook Authorization
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
            return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    // Push Notifications
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        print("Did register notification settings.")
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        print("Did register for push notifications.")
        let installation = PFInstallation.currentInstallation()
        installation?.setDeviceTokenFromData(deviceToken)
        installation?.saveInBackground()
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError
            error: NSError) {
            if error.code == 3010 {
                print("Push notifications are not supported in the iOS Simulator.")
            } else {
                print("application:didFailToRegisterForRemoteNotificationsWithError: %@", error)
            }
        }
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject: AnyObject]) {
        
        PFPush.handlePush(userInfo)
        
        if case(.Inactive) = application.applicationState {
            PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
        }
        
        if PFUser.currentUser() != nil {
            let tabBarController = self.window!.rootViewController as! HomeViewController
            let settingsTab = tabBarController.tabBar.items![2]
            
            if let badge = PFInstallation.currentInstallation()?.badge {
                settingsTab.badgeValue = String(badge + 1)
            }
            
            if UIApplication.sharedApplication().applicationState == .Active {
                PFInstallation.currentInstallation()?.badge += 1
            }
        }
    }
    
    // App Transitions
    func applicationWillEnterForeground(application: UIApplication) {
        if PFUser.currentUser() != nil {
            if PFInstallation.currentInstallation()?.badge != 0 {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let rootVC = storyboard.instantiateViewControllerWithIdentifier("HomeVC") as! HomeViewController
                self.window!.rootViewController = rootVC
                let settingsTab = rootVC.tabBar.items![2]
                settingsTab.badgeValue = String(PFInstallation.currentInstallation()?.badge)
            }
        }
    }

    func applicationDidBecomeActive(application: UIApplication) {
        FBSDKAppEvents.activateApp()
    }
    
    func integrateThirdPartyServices(withLaunchOptions launchOptions: [NSObject : AnyObject]?) -> Void {
        
        let configuration = ParseClientConfiguration {
            $0.applicationId = Service.Parse.appId
            $0.clientKey = Service.Parse.clientKey
            $0.server = Service.Parse.url
        }
        
        Parse.initializeWithConfiguration(configuration)
        // Facebook login integration
        PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions)
        // Flurry analytics integration
        Flurry.startSession(Service.Flurry.apiKey)
        Flurry.logEvent("Start Session")
        // Apptentive integration
        Apptentive.sharedConnection().APIKey = Service.Apptentive.apiKey
    }
    
    func setRootViewController(toViewController viewController: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        switch viewController {
        case "NoticeView":
            let noticeVC = storyboard.instantiateViewControllerWithIdentifier("NoticeView") as! NoticeViewController
            self.window?.rootViewController = noticeVC
        default:
            let homeVC = storyboard.instantiateViewControllerWithIdentifier("HomeVC") as! HomeViewController
            self.window?.rootViewController = homeVC
        }
    }
}
 
private extension Selector {
    static let didReceiveRemoteNotification = #selector(UIApplicationDelegate.application(_:didReceiveRemoteNotification:fetchCompletionHandler:))
}
