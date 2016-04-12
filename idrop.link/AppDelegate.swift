//
//  AppDelegate.swift
//  idrop.link
//
//  Created by Christian Schulze on 23/04/15.
//  Copyright (c) 2014 Christian Schulze, Tommy Leung. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate, NSMetadataQueryDelegate {
    
    @IBOutlet var window: NSWindow?
    @IBOutlet var popover : NSPopover?
    @IBOutlet weak var menu: NSMenu!
    @IBOutlet weak var loggedInMenu: NSMenu!
    @IBOutlet weak var popoverTableView: PopoverTableView!
    
    var user: User
    
    var preferencesWindowController: PreferencesWindowController
    var loginWindowController: LoginWindowController
    
    var popoverTableViewDelegate: PopoverTableViewDelegate
    
    let icon: IconView
    let item: NSStatusItem
    
    let query = NSMetadataQuery()
    
    override init() {
        let bar = NSStatusBar.systemStatusBar()
        
        let length: CGFloat = -1 // NSVariableStatusItemLength
        self.item = bar.statusItemWithLength(length)
        
        self.icon = IconView(item: item)
        item.view = icon
        
        self.user = User()
        
        // initialize window controller
        self.preferencesWindowController = PreferencesWindowController()
        self.preferencesWindowController.user = self.user
        self.loginWindowController = LoginWindowController()
        self.loginWindowController.user = self.user
        
        self.popoverTableViewDelegate =  PopoverTableViewDelegate()
        self.popoverTableViewDelegate.user = self.user
        
        super.init()
    }
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        // set up notification center delegate
        NSUserNotificationCenter.defaultUserNotificationCenter().delegate = self
        
        self.user.onProgress = { (prog: Float) -> Void in
            self.icon.progress = prog
        }
        
        // set up the popover drop listing (PopoverTableView)
        self.popoverTableView.setDelegate(self.popoverTableViewDelegate)
        self.popoverTableView.setDataSource(self.popoverTableViewDelegate)
        self.popoverTableView.user = self.user
        self.popoverTableViewDelegate.popoverTableView = self.popoverTableView
        
        // try to get data out of keychain if there is any. then try to login.
        // if both successfull, sync the drops and display them.
        if self.user.tryKeychainDataFetch() {
            self.user.tryLogin({ (success) -> Void in
                self.user.onDropSync = { () -> Void in
                    if let ptv = self.popoverTableView {
                        ptv.reloadData()
                    }
                }
                
                if (success) {
                    self.user.syncDrops()
                }
            })
        }

        // login was not successful anyways
        if self.user.userId == nil {
            self.login(self)
        }
        
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(queryUpdated), name: NSMetadataQueryDidStartGatheringNotification, object: query)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(queryUpdated), name: NSMetadataQueryDidUpdateNotification, object: query)
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(queryUpdated), name: NSMetadataQueryDidFinishGatheringNotification, object: query)
        query.delegate = self
        query.predicate = NSPredicate(format: "kMDItemIsScreenCapture = 1")
        query.startQuery()
    }
    
    func queryUpdated(notification: NSNotification) {
        let userInfo = notification.userInfo
        if let items = userInfo?[kMDQueryUpdateAddedItems] {
            let itemsAsArray = (items as! NSArray) as Array
            let item = itemsAsArray.last as! NSMetadataItem
            if let path = item.valueForAttribute(NSMetadataItemPathKey) {
                user.uploadDrop(path as! String, callback: { (success, msg) -> Void in
                    if (success) {
                        Notification.showNotification(NSURL(fileURLWithPath: path as! String).lastPathComponent!,
                            subtitle: "Drop successful!")
                    } else {
                        Notification.showNotification("idrop.link",
                            subtitle: "Drop failed.")
                    }
                })
            }
        }
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        query.stopQuery()
    }
    
    override func awakeFromNib() {
        let edge = NSRectEdge.MinY
        let icon = self.icon
        let rect = icon.frame

        // set up interaction with the iconView in the menu bar
        icon.onMouseDown = {
            if (icon.isSelected) {
                self.popover?.showRelativeToRect(rect,
                    ofView: icon,
                    preferredEdge: edge)
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
                    Notification.showNotification(NSURL(fileURLWithPath: file).lastPathComponent!,
                        subtitle: "Drop successful!")
                } else {
                    Notification.showNotification("idrop.link",
                        subtitle: "Drop failed.")
                }
            })
        }
    }
    
    // MARK: - Notification Center Delegation
    func userNotificationCenter(center: NSUserNotificationCenter,
        shouldPresentNotification notification: NSUserNotification) -> Bool {
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

