//
//  PopoverTableViewDelegate.swift
//  idrop.link
//
//  Created by Christian Schulze on 31/05/15.
//  Copyright (c) 2015 andinfinity. All rights reserved.
//

import Cocoa

class PopoverTableViewDelegate: NSObject, NSTableViewDataSource, NSTableViewDelegate {
    var user:User? {
        didSet {
            println("has user")
        }
    }
    
    override init() {
        self.user = nil
    }
    
    init(user:User) {
        self.user = user
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        if let usr = self.user {
            return usr.drops.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if let usr = self.user {
            var cell = tableView.makeViewWithIdentifier("MainCell", owner: self) as! PopoverTableCellView
            cell.imgView = nil
            cell.titleTextField?.stringValue = usr.drops[row].name!
            
            if let date = usr.drops[row].dropDate {
                cell.dateTextField?.stringValue = date
            } else {
                cell.dateTextField?.stringValue = ""
            }

            
            return cell
        } else {
            println("no usr @ PTVD.tv")
            return nil
        }
    }
}
