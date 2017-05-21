//
//  AppDelegate.swift
//  nmf
//
//  Created by Daniel Pagan on 3/16/16.
//  Copyright © 2017 Nelsonville Music Festival. All rights reserved.
//

import UIKit
import Fabric
import TwitterKit
import BBBadgeBarButtonItem
import Pushwoosh
import ReachabilitySwift
import Kingfisher

#if CONFIGURATION_Debug
import SimulatorStatusMagic
#endif


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, PushNotificationDelegate {
    
    let APP_ID = Secrets.secrets()["APP_ID"] as? String
    let SECRET_KEY = Secrets.secrets()["SECRET_KEY"] as? String
    let VERSION_NUM =  "v1"
    
    let backendless = Backendless.sharedInstance()

    var window: UIWindow?
    
    var lastActive = Date()
    
    let reachability = Reachability()!
 
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        backendless?.initApp(APP_ID, secret: SECRET_KEY, version: VERSION_NUM)
        
        
        // setup image cache
        ImageCache.default.maxCachePeriodInSecond = 30 * 24 * 60 * 60

        DataStore.sharedInstance.updateScheduleItems { _ in
            return
        }
        DataStore.sharedInstance.updateArtistItems { _ in
            if self.reachability.isReachableViaWiFi {
                ImagePrefetcher.init(resources: DataStore.sharedInstance.artistItems, options: nil, progressBlock: nil, completionHandler: nil).start()
            }
            
            return
        }
        
        // setup twitter kit
        Twitter.sharedInstance().start(withConsumerKey: Secrets.secrets()["TWITTERKIT_KEY"] as! String, consumerSecret: Secrets.secrets()["TWITTERKIT_SECRET"] as! String)
        
        Fabric.with([Twitter.self])
        
        // setup push notes
        #if CONFIGURATION_Release
            PushNotificationManager.initialize(withAppCode: Secrets.secrets()["PW_APP_CODE"] as! String, appName: "NMF")
        #endif
        
        #if CONFIGURATION_Debug
            PushNotificationManager.initialize(withAppCode: Secrets.secrets()["PW_DEV_APP_CODE"] as! String, appName: "NMF-dev")
        #endif
        
        PushNotificationManager.push().delegate = self
        PushNotificationManager.push().showPushnotificationAlert = true
        PushNotificationManager.push().handlePushReceived(launchOptions)
        PushNotificationManager.push().sendAppOpen()
        PushNotificationManager.push().registerForPushNotifications()
        
        #if CONFIGURATION_Debug
            // for nice screen shots only
            SDStatusBarManager.sharedInstance().enableOverrides()
        #endif
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.

        lastActive = Date()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        DataStore.sharedInstance.saveData()
        
        lastActive = Date()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        if lastActive > Date(timeIntervalSinceNow: -(10*60)) {
            // if app hasn't been used in 10 minutes, update it, otherwise return
            return
        }
        
        guard let tabController = window?.rootViewController as? UITabBarController,
            let navController = tabController.selectedViewController as? UINavigationController,
            let scheduleViewController = navController.visibleViewController as? ScheduleTableViewController else {
                return
        }

        DataStore.sharedInstance.updateScheduleItems() { error in
            if error == nil {
                scheduleViewController.sortScheduleItems(starredOnly: scheduleViewController.showingStarredOnly)
                
                scheduleViewController.tableView.reloadData()
            }
            
            scheduleViewController.scrollToNearestCell()
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        DataStore.sharedInstance.saveData()
    }
    
    // MARK: - Push notifications
    
     func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        PushNotificationManager.push().handlePushRegistration(deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        PushNotificationManager.push().handlePushRegistrationFailure(error)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        PushNotificationManager.push().handlePushReceived(userInfo)
        
        guard let tabController = window?.rootViewController as? UITabBarController,
            let navController = tabController.viewControllers?.flatMap({ $0 as? UINavigationController }).filter({ $0.viewControllers.first is ScheduleTableViewController}).first,
            let scheduleController = navController.viewControllers.first as? ScheduleTableViewController else {
                return
        }

        if let button = scheduleController.navigationItem.leftBarButtonItem as? BBBadgeBarButtonItem {
            button.badgeValue = "!"
        }
    }
    
    func onPushAccepted(_ pushManager: PushNotificationManager!, withNotification pushNotification: [AnyHashable: Any]!, onStart: Bool) {
        print("Push notification accepted: \(pushNotification)");
        
        guard let tabController = window?.rootViewController as? UITabBarController,
            let navController = tabController.viewControllers?.flatMap({ $0 as? UINavigationController }).filter({ $0.viewControllers.first is ScheduleTableViewController}).first,
            let scheduleController = navController.viewControllers.first as? ScheduleTableViewController else {
                return
        }
        
        tabController.selectedViewController = navController
        navController.popToRootViewController(animated: true)
        scheduleController.notificationsAction(self)
        
        
        
//        let activeViewContoller = navController.visibleViewController as? ScheduleTableViewController else {
//                return
//        }
        
//        let alertController = UIAlertController(title: "Heads Up!", message: pushNotification["body"], preferredStyle: <#T##UIAlertControllerStyle#>)
    }

}

