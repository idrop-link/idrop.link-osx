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
    @IBOutlet weak var apiURL: NSTextField!
    @IBOutlet weak var apiURLSpinner: NSProgressIndicator!
    @IBOutlet weak var uploadScreenshots: NSButton!

    // User Tab
    @IBOutlet weak var email: NSTextField!
    
    var user: User?

    var appUrl: NSURL?
    
    @IBAction func changeTab(sender: AnyObject) {
        let sndr = sender as! NSToolbarItem
        
        switch sndr.tag {
        case 1:
            tabView.selectTabViewItem(generalTab)
        case 2:
            tabView.selectTabViewItem(userTab)
        default:
            break;
        }
    }

    @IBAction func persistToLoginItems(sender: AnyObject) {
        if doOpenAtStartup.state == NSOnState {
            LoginItemController.setLaunchAtLogin(self.appUrl!, enabled: true)
        } else if doOpenAtStartup.state == NSOffState {
            LoginItemController.setLaunchAtLogin(self.appUrl!, enabled: false)
        } else {
            // well, this is the "NSMixedState". though it should not apply
            // here we log this just in case
            print("Detected invalid button state `NSMixedState` @ Preferences->Global->Start at Login")
        }
    }

    @IBAction func useApiUrl(sender: AnyObject) {
        Swift.print("useApiUrl called")
        let url = apiURL.stringValue

        if url.characters.count == 0 {
            return
        }

        apiURLSpinner.hidden = false
        apiURLSpinner.startAnimation(self)

        Networking.checkAPI(url, callback: { (returnedJson, error) -> Void in
            self.apiURLSpinner.stopAnimation(self)
            self.apiURLSpinner.hidden = true

            // TODO: actually change the api instance
            if let err = error {
                Swift.print(err.userInfo["message"])
            } else if let json = returnedJson {
                if json["_links"]["self"]["href"] == "/api/v1" {
                    Swift.print("success")
                } else {
                    Swift.print("failed")
                }
            }
        })
    }

    
    override func awakeFromNib() {
        var deactivate:Bool = true
        self.appUrl = NSURL.fileURLWithPath(NSBundle.mainBundle().bundlePath)

        self.apiURL.stringValue = Networking.getAPIURI()

        if let usr = self.user {
            if let mail = usr.email {
                self.email.stringValue = mail
                deactivate = false
            }
        }

        if deactivate {
            self.email.enabled = false
        }

        if let _ = self.appUrl {
            if LoginItemController.willLaunchAtLogin(self.appUrl!) {
                doOpenAtStartup.state = NSOnState
            } else {
                doOpenAtStartup.state = NSOffState
            }
        } else {
            // we can't save it anyway
            doOpenAtStartup.enabled = false
        }
    }
}