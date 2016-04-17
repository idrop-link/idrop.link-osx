//
//  ScreenshotDetector.swift
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
class ScreenshotDetector : NSObject, NSMetadataQueryDelegate {
    
    var listener: ((String) -> Void)?
    private let query = NSMetadataQuery()
    
    override init() {
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
            let items = (notification.userInfo![kMDQueryUpdateAddedItems] as! NSArray) as Array
            for item in items {
                let path = item.valueForAttribute(NSMetadataItemPathKey) as! String
                listener!(path)
            }
        }
    }
}