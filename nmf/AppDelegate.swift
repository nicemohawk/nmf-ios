//
//  AppDelegate.swift
//  nmf
//
//  Created by Daniel Pagan on 3/16/16.
//  Copyright © 2016 Nelsonville Music Festival. All rights reserved.
//

import UIKit
#if CONFIGURATION_Debug
import SimulatorStatusMagic
#endif


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {
    
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
        
        #if CONFIGURATION_Debug
            SDStatusBarManager.sharedInstance().enableOverrides()
        #endif
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
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
        
        if lastActive.earlierDate(NSDate(timeIntervalSinceNow: -(5*60))) != lastActive {
            // if app hasn't been used in 5 minutes, update it, otherwise return
            return
        }
        
        guard let tabController = window?.rootViewController as? UITabBarController,
            let navController = tabController.selectedViewController as? UINavigationController,
            let scheduleViewController = navController.visibleViewController as? ScheduleTableViewController else {
                return
        }
        
        scheduleViewController.scrollToNearestCell()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        DataStore.sharedInstance.saveData()
    }

}

