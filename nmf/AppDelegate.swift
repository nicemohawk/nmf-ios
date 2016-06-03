//
//  AppDelegate.swift
//  nmf
//
//  Created by Daniel Pagan on 3/16/16.
//  Copyright © 2016 Nelsonville Music Festival. All rights reserved.
//

import UIKit
import Fabric
import TwitterKit
import BBBadgeBarButtonItem

#if CONFIGURATION_Debug
import SimulatorStatusMagic
#endif


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, PushNotificationDelegate {
    
    let APP_ID = "49259415-337F-9D60-FFEE-023C6FD21C00"
    let SECRET_KEY = "71BC7DA3-EFB8-26C2-FF59-599860222C00"
    let VERSION_NUM =  "v1"
    
    let backendless = Backendless.sharedInstance()

    var window: UIWindow?
    
    var lastActive = NSDate()
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        backendless.initApp(APP_ID, secret: SECRET_KEY, version: VERSION_NUM)
        
        DataStore.sharedInstance.updateScheduleItems { _ in
            return
        }
        DataStore.sharedInstance.updateArtistItems { _ in
            return
        }
        
        // setup twitter kit
        Fabric.with([Twitter.self])
        
        // setup push notes
        #if CONFIGURATION_Release
            PushNotificationManager.initializeWithAppCode("BA4B0-6DAEE", appName: "NMF")
        #endif
        
        #if CONFIGURATION_Debug
            PushNotificationManager.initializeWithAppCode("2312C-C345D", appName: "NMF-dev")
        #endif
        
        PushNotificationManager.pushManager().delegate = self
        PushNotificationManager.pushManager().showPushnotificationAlert = true
        PushNotificationManager.pushManager().handlePushReceived(launchOptions)
        PushNotificationManager.pushManager().sendAppOpen()
        PushNotificationManager.pushManager().registerForPushNotifications()
        
        #if CONFIGURATION_Debug
            // for nice screen shots only
            SDStatusBarManager.sharedInstance().enableOverrides()
        #endif
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.

        lastActive = NSDate()
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        DataStore.sharedInstance.saveData()
        
        lastActive = NSDate()
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        if lastActive.earlierDate(NSDate(timeIntervalSinceNow: -(10*60))) != lastActive {
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

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        DataStore.sharedInstance.saveData()
    }
    
    // MARK: - Push notifications
    
     func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        PushNotificationManager.pushManager().handlePushRegistration(deviceToken)
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        PushNotificationManager.pushManager().handlePushRegistrationFailure(error)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        PushNotificationManager.pushManager().handlePushReceived(userInfo)
        
        guard let tabController = window?.rootViewController as? UITabBarController,
            let navController = tabController.viewControllers?.flatMap({ $0 as? UINavigationController }).filter({ $0.viewControllers.first is ScheduleTableViewController}).first,
            let scheduleController = navController.viewControllers.first as? ScheduleTableViewController else {
                return
        }

        if let button = scheduleController.navigationItem.leftBarButtonItem as? BBBadgeBarButtonItem {
            button.badgeValue = "!"
        }
    }
    
    func onPushAccepted(pushManager: PushNotificationManager!, withNotification pushNotification: [NSObject : AnyObject]!, onStart: Bool) {
        print("Push notification accepted: \(pushNotification)");
        
        guard let tabController = window?.rootViewController as? UITabBarController,
            let navController = tabController.viewControllers?.flatMap({ $0 as? UINavigationController }).filter({ $0.viewControllers.first is ScheduleTableViewController}).first,
            let scheduleController = navController.viewControllers.first as? ScheduleTableViewController else {
                return
        }
        
        tabController.selectedViewController = navController
        navController.popToRootViewControllerAnimated(true)
        scheduleController.notificationsAction(self)
        
        
        
//        let activeViewContoller = navController.visibleViewController as? ScheduleTableViewController else {
//                return
//        }
        
//        let alertController = UIAlertController(title: "Heads Up!", message: pushNotification["body"], preferredStyle: <#T##UIAlertControllerStyle#>)
    }

}

