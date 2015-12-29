//
//  Notification.swift
//  idrop.link
//
//  Created by Christian Schulze on 04/05/15.
//  Copyright (c) 2015 andinfinity. All rights reserved.
//

import Cocoa

public class Notification: NSObject {
    public class func showNotification(title: String, subtitle: String,
        informativeText: String? = nil) {
            let notification:NSUserNotification = NSUserNotification()
            notification.title = title
            notification.subtitle = subtitle

            if let iText = informativeText {
                notification.informativeText = iText
            }

            notification.soundName = NSUserNotificationDefaultSoundName

            NSUserNotificationCenter
                .defaultUserNotificationCenter()
                .scheduleNotification(notification)
    }
}
