//
//  AppDelegate.swift
//  idrop.link
//
//  Created by Christian Schulze on 23/04/15.
//  Copyright (c) 2014 Christian Schulze, Tommy Leung. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate {
    @IBOutlet var window: NSWindow?
    @IBOutlet var popover : NSPopover?
    @IBOutlet weak var menu: NSMenu!
    @IBOutlet weak var loggedInMenu: NSMenu!
    @IBOutlet weak var popoverTableView: NSScrollView!
    
    var user: User
    
    var preferencesWindowController: PreferencesWindowController
    var loginWindowController: LoginWindowController
    
    let icon: IconView
    let item: NSStatusItem
    
    override init() {
        let bar = NSStatusBar.systemStatusBar();
        
        let length: CGFloat = -1 // NSVariableStatusItemLength
        self.item = bar.statusItemWithLength(length);
        
        self.icon = IconView(item: item);
        item.view = icon;
        
        self.user = User()
        
        // try to get data out of keychain if any
        if self.user.tryKeychainDataFetch() {
            self.user.tryLogin({ (success) -> Void in
                    // Does nothing atm
                })
        }
        
        // initialize window controller
        self.preferencesWindowController = PreferencesWindowController()
        self.preferencesWindowController.user = self.user
        self.loginWindowController = LoginWindowController()
        self.loginWindowController.user = self.user
        
        super.init();
    }
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        // set up notification center delegate
        NSUserNotificationCenter.defaultUserNotificationCenter().delegate = self
        
        self.user.onProgress = { (prog: Float) -> Void in
            self.icon.progress = prog
        }
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    override func awakeFromNib() {
        let edge = NSMinYEdge
        let icon = self.icon
        let rect = icon.frame
        
        icon.onMouseDown = {
            if (icon.isSelected) {
                self.popover?.showRelativeToRect(rect, ofView: icon, preferredEdge: edge);
                return
            }
            
            self.popover?.close()
        }
        
        icon.onRightMouseDown = {
            if (icon.isSelected) {
                self.popover?.close()
                
                if (self.user.hasCredentials()) {
                    self.item.popUpStatusItemMenu(self.loggedInMenu)
                } else {
                    self.item.popUpStatusItemMenu(self.menu)
                }
            }
        }
        
        icon.onDrop = { (file: String) -> () in
            self.user.uploadDrop(file, callback: { (success, msg) -> Void in
                if (success) {
                    Notification.showNotification(file.lastPathComponent, subtitle: "Drop successful!")
                } else {
                    Notification.showNotification("idrop.link", subtitle: "Drop failed.")
                }
            })
        }
    }
    
    // MARK: - Notification Center Delegation
    func userNotificationCenter(center: NSUserNotificationCenter, shouldPresentNotification notification: NSUserNotification) -> Bool {
        return true
    }
    
    // MARK: - Menu Handlers
    @IBAction func quitApplication(sender: AnyObject) {
        NSApplication.sharedApplication().terminate(self)
    }
    
    @IBAction func showPreferencesWindow(sender: AnyObject) {
        // focus on our app
        NSApplication.sharedApplication().activateIgnoringOtherApps(true)
        
        // show window
        NSBundle.mainBundle().loadNibNamed("Preferences",
            owner: preferencesWindowController, topLevelObjects: nil)
    }
    
    @IBAction func login(sender: AnyObject) {
        // focus on our app
        NSApplication.sharedApplication().activateIgnoringOtherApps(true)
        
        // show window
        NSBundle.mainBundle().loadNibNamed("Login",
            owner: self.loginWindowController, topLevelObjects: nil)
    }

    @IBAction func logout(sender: AnyObject) {
        self.user.logout()
    }
}

