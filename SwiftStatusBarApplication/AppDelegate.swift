//
//  AppDelegate.swift
//  SwiftStatusBarApplication
//
//  Created by Tommy Leung on 6/7/14.
//  Copyright (c) 2014 Tommy Leung. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    @IBOutlet var window: NSWindow?
    @IBOutlet var popover : NSPopover?
    @IBOutlet weak var menu: NSMenu!
    
    let icon: IconView;
    let item: NSStatusItem
    
    override init() {
        let bar = NSStatusBar.systemStatusBar();
        
        let length: CGFloat = -1 //NSVariableStatusItemLength
        self.item = bar.statusItemWithLength(length);
        
        self.icon = IconView(imageName: "icon", item: item);
        item.view = icon;
        
        super.init();
    }
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
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
        
        // temp variables for closure
        var item = self.item
        var _menu = self.menu
        
        icon.onRightMouseDown = {
            if (icon.isSelected) {
                self.popover?.close()
                item.popUpStatusItemMenu(_menu)
            }
        }
    }
    
    // MARK: - Menu Handlers
    
    @IBAction func quitApplication(sender: AnyObject) {
        NSApplication.sharedApplication().terminate(self)
    }
}

