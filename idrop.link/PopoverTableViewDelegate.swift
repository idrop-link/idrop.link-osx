//
//  PopoverTableViewDelegate.swift
//  idrop.link
//
//  Created by Christian Schulze on 31/05/15.
//  Copyright (c) 2015 andinfinity. All rights reserved.
//

import Cocoa
import AppKit

class PopoverTableViewDelegate: NSObject, NSTableViewDataSource, NSTableViewDelegate {
    var popoverTableView: PopoverTableView?
    var user:User?

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
            let cell = tableView.makeViewWithIdentifier("MainCell", owner: self) as! PopoverTableCellView
            cell.imgView = nil
            cell.titleTextField?.stringValue = usr.drops[row].name!

            if let date = usr.drops[row].dropDate {
                cell.dateTextField?.stringValue = date
            } else {
                cell.dateTextField?.stringValue = ""
            }

            return cell
        } else {
            return nil
        }
    }

    func tableViewSelectionDidChange(notification: NSNotification) {
        // sets selected items in bold font
        self.popoverTableView?.enumerateAvailableRowViewsUsingBlock({ (rowView, row) -> Void in
            for (var col = 0; col < rowView.numberOfColumns; col += 1) {
                let cellView: AnyObject? = rowView.viewAtColumn(col)

                if let cV: AnyObject = cellView {
                    if (cV.isKindOfClass(PopoverTableCellView)) {
                        let tabelCellView = cV as! PopoverTableCellView
                        let dateLabel = tabelCellView.dateTextField
                        let titleLabel = tabelCellView.titleTextField

                        if (rowView.selected) {
                            dateLabel?.font = NSFont.boldSystemFontOfSize(dateLabel!.font!.pointSize)
                            titleLabel?.font = NSFont.boldSystemFontOfSize(titleLabel!.font!.pointSize)

                        } else {
                            dateLabel?.font = NSFont.systemFontOfSize(dateLabel!.font!.pointSize)
                            titleLabel?.font = NSFont.systemFontOfSize(titleLabel!.font!.pointSize)
                        }
                    }
                }
            }
        })
    }
    
}
