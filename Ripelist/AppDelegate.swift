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
    
    lazy var returningUser: AnyObject? = {
        return UserDefaults.standard.object(forKey: "hasLaunchedOnce")
    }() as AnyObject?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // White status bar
        application.setStatusBarStyle(.lightContent, animated: false)
        
        setRootVC(returningUser)
        integrateSDKs(launchOptions)
        
        if application.applicationState != .background {
            
            // 2
            let preBackgroundPush = !application.responds(to: #selector(getter: UIApplication.backgroundRefreshStatus))
            let oldPushHandlerOnly = !self.responds(to: .didReceiveRemoteNotification)
            var pushPayload = false
            if let options = launchOptions {
                pushPayload = options[UIApplicationLaunchOptionsKey.remoteNotification] != nil
            }
            if (preBackgroundPush || oldPushHandlerOnly || pushPayload) {
                PFAnalytics.trackAppOpened(launchOptions: launchOptions)
            }
        }
        
        // 3
        let types: UIUserNotificationType = [.alert, .badge, .sound]
        let settings = UIUserNotificationSettings(types: types, categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        
        // Return from the Facebook SDK
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    fileprivate func setRootVC(_ returningUser: AnyObject?) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        switch returningUser {
        case nil:
            window?.rootViewController = storyboard.instantiateViewController(withIdentifier: "NoticeVC") as? NoticeViewController
        default:
            window?.rootViewController = storyboard.instantiateViewController(withIdentifier: "HomeVC") as? HomeViewController
        }
    }
    
    fileprivate func integrateSDKs(_ launchOptions: [AnyHashable: Any]?) -> Void {
        // Parse configuration
        let config = ParseClientConfiguration {
            $0.applicationId = Service.Parse.appId
            $0.clientKey = Service.Parse.clientKey
            $0.server = Service.Parse.url
        }
        Parse.initialize(with: config)
        // Facebook login integration
        PFFacebookUtils.initializeFacebook(applicationLaunchOptions: launchOptions)
        // Flurry analytics integration
        Flurry.startSession(Service.Flurry.apiKey)
        // Apptentive integration
        Apptentive.sharedConnection().apiKey = Service.Apptentive.apiKey
    }
    
    // Facebook Authorization
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
            return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    // Push Notifications
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let installation = PFInstallation.current()
        installation?.setDeviceTokenFrom(deviceToken)
        installation?.saveInBackground()
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError
            error: NSError) {
            if error.code == 3010 {
                print("Push notifications are not supported in the iOS Simulator.")
            } else {
                print("application:didFailToRegisterForRemoteNotificationsWithError: %@", error)
            }
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        
        PFPush.handle(userInfo)
        
        if case(.inactive) = application.applicationState {
            PFAnalytics.trackAppOpened(withRemoteNotificationPayload: userInfo)
        }
        
        if PFUser.current() != nil {
            let tabBarController = self.window!.rootViewController as! HomeViewController
            let settingsTab = tabBarController.tabBar.items![2]
            
            if let badge = PFInstallation.current()?.badge {
                settingsTab.badgeValue = String(badge + 1)
            }
            
            if UIApplication.shared.applicationState == .active {
                PFInstallation.current()?.badge += 1
            }
        }
    }
    
    // App Transitions
    func applicationWillEnterForeground(_ application: UIApplication) {
        if PFUser.current() != nil {
            if PFInstallation.current()?.badge != 0 {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let rootVC = storyboard.instantiateViewController(withIdentifier: "HomeVC") as! HomeViewController
                self.window!.rootViewController = rootVC
                let settingsTab = rootVC.tabBar.items![2]
                settingsTab.badgeValue = String(describing: PFInstallation.current()?.badge)
            }
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        FBSDKAppEvents.activateApp()
    }
    
}
