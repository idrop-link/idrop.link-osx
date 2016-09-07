//
//  ScreenshotController.swift
//  idrop.link
//
//  Created by Daniel Seemaier on 13/04/16.
//  Copyright © 2016 andinfinity. All rights reserved.
//

import Cocoa

/**
 This class detects newly created screnshots and signals a user provided 
 listener upon detection.
*/
class ScreenshotController : NSObject, NSMetadataQueryDelegate {
    
    var listener: ((String) -> Void)?
    var userDefaults: NSUserDefaults
    private let query = NSMetadataQuery()
    
    override init() {
        self.userDefaults = NSUserDefaults.standardUserDefaults()
        super.init()
        
        NSNotificationCenter.defaultCenter()
            .addObserver(self,
                         selector: #selector(queryUpdated),
                         name: NSMetadataQueryDidUpdateNotification,
                         object: query)
        
        query.delegate = self
        query.predicate = NSPredicate(format: "kMDItemIsScreenCapture = 1")
    }
    
    func start() {
        query.startQuery()
    }
    
    func stop() {
        query.stopQuery()
    }
    
    @objc private func queryUpdated(notification: NSNotification) {
        if listener == nil {
            return // ignore detection
        }
        
        if notification.userInfo != nil && notification.userInfo![kMDQueryUpdateAddedItems] != nil {
            let autoUpload = self.userDefaults.boolForKey("auto-upload")
            if !autoUpload {
                // ignore because of user preferences set to "not auto upload"
                return
            }

            let items = (notification.userInfo![kMDQueryUpdateAddedItems] as! NSArray) as Array
            for item in items {
                let path = item.valueForAttribute(NSMetadataItemPathKey) as! String
                listener!(path)
            }
        }
    }
}