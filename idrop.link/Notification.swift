//
//  Notification.swift
//  idrop.link
//
//  Created by Christian Schulze on 04/05/15.
//  Copyright (c) 2015 andinfinity. All rights reserved.
//

import Cocoa

public class Notification: NSObject {
    public class func showNotification(title: String, subtitle: String) {
        var notification:NSUserNotification = NSUserNotification()
        notification.title = title
        notification.subtitle = subtitle
        
        NSUserNotificationCenter.defaultUserNotificationCenter().scheduleNotification(notification)
    }
}
