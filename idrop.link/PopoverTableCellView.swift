//
//  PopoverTableCellView.swift
//  idrop.link
//
//  Created by Christian Schulze on 31/05/15.
//  Copyright (c) 2015 andinfinity. All rights reserved.
//

import Cocoa

class PopoverTableCellView: NSTableCellView {
    @IBOutlet var imgView:NSImageView?
    @IBOutlet var titleTextField:NSTextField?
    @IBOutlet var dateTextField:NSTextField?
    
    /*
    override var backgroundStyle: NSBackgroundStyle {
        set {
            if let rowView = self.superview as? PopoverTableRowView {
                super.backgroundStyle = rowView.selected ? NSBackgroundStyle.Dark : NSBackgroundStyle.Light
            } else {
                super.backgroundStyle = newValue
            }
            self.udpateSelectionHighlight()
        }
        
        get {
            return super.backgroundStyle;
        }
    }
    
    func udpateSelectionHighlight() {
        // this code can be used to alter the text colors
        // programatically if row is selected
        if ( self.backgroundStyle == NSBackgroundStyle.Dark ) {
            self.titleTextField?.textColor = NSColor.whiteColor()
        } else {
            self.titleTextField?.textColor = NSColor.blackColor()
        }
        
        self.dateTextField?.textColor = NSColor.secondaryLabelColor()

    }
    */
}
