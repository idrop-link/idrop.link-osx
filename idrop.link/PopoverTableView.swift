//
//  PopoverTableView.swift
//  idrop.link
//
//  Created by Christian Schulze on 31/05/15.
//  Copyright (c) 2015 andinfinity. All rights reserved.
//

import Cocoa

class PopoverTableView: NSTableView {
    override func awakeFromNib() {
        self.enclosingScrollView?.drawsBackground = false
        self.enclosingScrollView?.borderType = NSBorderType.NoBorder
        self.headerView = nil
        self.backgroundColor = NSColor.clearColor()
    }
}
