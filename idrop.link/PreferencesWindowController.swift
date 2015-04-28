//
//  PreferencesWindowController.swift
//  idrop.link
//
//  Created by Christian Schulze on 17/04/15.
//  Copyright (c) 2015 Christian Schulze. All rights reserved.
//

import Foundation
import Cocoa

/**
WindowController for the Preferences window.
*/
class PreferencesWindowController: NSWindowController {
    @IBOutlet var _window: NSWindow!
    @IBOutlet weak var tabView: NSTabView!
    
    // Tabs
    @IBOutlet weak var generalTab: NSTabViewItem!
    @IBOutlet weak var userTab: NSTabViewItem!
    
    // General Tab
    @IBOutlet weak var doOpenAtStartup: NSButton!
    
    // User Tab
    @IBOutlet weak var email: NSTextField!
    
    var user: User?
    
    @IBAction func changeTab(sender: AnyObject) {
        var sndr = sender as! NSToolbarItem
        
        switch sndr.tag {
        case 1:
            tabView.selectTabViewItem(generalTab)
        case 2:
            tabView.selectTabViewItem(userTab)
        default:
            break;
        }
    }
    
    override func awakeFromNib() {
        if let usr = self.user {
            self.email.stringValue = usr.email!
        }
    }
}