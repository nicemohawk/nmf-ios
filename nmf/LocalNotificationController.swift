//
//  LocalNotificationController.swift
//  nmf
//
//  Created by Ben Lachman on 5/28/17.
//  Copyright © 2017 Nelsonville Music Festival. All rights reserved.
//

import UIKit

class LocalNotificationController {
    static let shared = LocalNotificationController()

    var notificationsEnabled: Bool {
        didSet {
            let previousState = UserDefaults.standard.bool(forKey: "SetsLocalNotifications")

            UserDefaults.standard.set(notificationsEnabled, forKey: "SetsLocalNotifications")

            if notificationsEnabled != previousState {
                if notificationsEnabled == true {
                    scheduleNotifications()
                } else {
                    clearNotifications()
                }
            }
        }
    }

    private init() {
        if UserDefaults.standard.object(forKey: "SetsLocalNotifications") != nil {
            notificationsEnabled = UserDefaults.standard.bool(forKey: "SetsLocalNotifications")
        } else {
            notificationsEnabled = true
        }
    }

    func scheduleNotifications() {
        guard notificationsEnabled else { return }

        var notifications = [UILocalNotification]()

        for item in DataStore.sharedInstance.scheduleItems {
            if item.starred, let notification = localNotification(for: item) {
                notifications.append(notification)
            }
        }

        UIApplication.shared.scheduledLocalNotifications = notifications
    }

    func clearNotifications() {
        UIApplication.shared.cancelAllLocalNotifications()
    }

    func scheduleNotification(for item: Schedule) {
        guard notificationsEnabled else { return }

        if let notification = localNotification(for: item) {
            UIApplication.shared.scheduleLocalNotification(notification)
        }
    }

    func clearNotification(for item: Schedule) {
        guard let scheduledNotifications = UIApplication.shared.scheduledLocalNotifications else { return }

        for notification in scheduledNotifications {
            if let objectId = notification.userInfo?["objectId"] as? String, objectId == item.objectId {
                UIApplication.shared.cancelLocalNotification(notification)
            }
        }
    }

    func localNotification(for item:Schedule) -> UILocalNotification? {
        guard item.starred else { print("\(item) is not starred! Not creating notification."); return nil }

        if let fireDate = item.starttime, fireDate > Date(), let objectId = item.objectId {
            let notification = UILocalNotification()
            notification.fireDate = fireDate

            notification.userInfo = ["objectId": objectId]

            if let stage = item.stage {
                notification.alertBody = "\(item.artist ?? "One of your starred artists") is starting soon on the \(stage)!"
            } else {
                notification.alertBody = "\(item.artist ?? "One of your starred artists") is starting soon!"
            }

            return notification
        }
        
        return nil
    }
}
