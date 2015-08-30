//
//  PopoverTableView.swift
//  idrop.link
//
//  Created by Christian Schulze on 31/05/15.
//  Copyright (c) 2015 andinfinity. All rights reserved.
//

import Cocoa

class PopoverTableView: NSTableView {
    var user: User?

    override func awakeFromNib() {
        // refine drawing (for the NSTableView as well
        // as for the enclosing NSScrollView). we want to
        // be completely transparent. to reach this, we
        // have to do the following:
        //     * remove any border
        //     * remove any background
        //     * remove header
        self.enclosingScrollView?.drawsBackground = false
        self.enclosingScrollView?.borderType = NSBorderType.NoBorder
        self.headerView = nil
        self.backgroundColor = NSColor.clearColor()

        // wire up action executed on double click
        // note that we have to use a selector
        // due to the underlying cocoa logic which is
        // written in Objective-C
        self.doubleAction = "onDoubleAction:" as Selector

        // the message which is being sent to the selector
        // declared above should be delivered to this very
        // object (well, actually its instance(s))
        self.target = self
    }

    /**
    Gets executed on double click. Every cell represents a drop
    which has a URL. This URL gets openend in the default browser.

    :param: sender The sender

    :see: doubleAction (attribute)
    :see: target (attribute)
    */
    func onDoubleAction(sender: AnyObject) {
        if let usr = self.user {
            if usr.drops.count >= self.selectedRow {
                if let url = usr.drops[self.selectedRow].url {
                    var _url = NSURL(string: url) as! CFURLRef
                    LSOpenCFURLRef(_url, nil)
                }
            }
        }
    }

}
