//
//  IconView.swift
//  idrop.link
//
//  Created by Tommy Leung on 6/7/14.
//  Copyright (c) 2014 Christian Schulze, Tommy Leung. All rights reserved.
//

import Foundation
import Cocoa

class IconView : NSView {
    @IBOutlet var mainMenu: NSMenu?

    private(set) var image: NSImage
    private(set) var image0: NSImage
    private(set) var image25: NSImage
    private(set) var image50: NSImage
    private(set) var image75: NSImage

    private(set) var lightImage: NSImage
    private(set) var lightImage0: NSImage
    private(set) var lightImage25: NSImage
    private(set) var lightImage50: NSImage
    private(set) var lightImage75: NSImage

    private let item: NSStatusItem

    var onMouseDown: () -> ()
    var onRightMouseDown: () -> ()
    var onDrop: (String) -> ()

    var progress:Float {
        didSet { self.needsDisplay = true }
    }

    var isSelected: Bool {
        didSet {
            // redraw if isSelected changes for bg highlight
            if (isSelected != oldValue) {
                self.needsDisplay = true
            }
        }
    }

    // MARK: - init
    init(item: NSStatusItem) {
        self.image = NSImage(named: "icon")!
        self.image0 = NSImage(named: "icon_0")!
        self.image25 = NSImage(named: "icon_25")!
        self.image50 = NSImage(named: "icon_50")!
        self.image75 = NSImage(named: "icon_75")!

        self.lightImage = NSImage(named: "iconlight")!
        self.lightImage0 = NSImage(named: "iconlight_0")!
        self.lightImage25 = NSImage(named: "iconlight_25")!
        self.lightImage50 = NSImage(named: "iconlight_50")!
        self.lightImage75 = NSImage(named: "iconlight_75")!

        self.progress = 1.0

        self.item = item
        self.isSelected = false
        self.onMouseDown = {}
        self.onRightMouseDown = {}
        self.onDrop = { (str) -> Void in
        }

        let thickness = NSStatusBar.systemStatusBar().thickness
        let rect = CGRectMake(0, 0, thickness, thickness)

        super.init(frame: rect)

        // register for drag n drop
        registerForDraggedTypes([NSURLPboardType])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func drawRect(dirtyRect: NSRect) {
        self.item.drawStatusBarBackgroundInRect(dirtyRect, withHighlight: self.isSelected)

        let size = self.image.size
        let rect = CGRectMake(2, 2, size.width, size.height)

        let isDarkmode = (NSAppearance.currentAppearance().name.rangeOfString(NSAppearanceNameVibrantDark) != nil)

        if self.isSelected || isDarkmode {
            if self.progress < 0.25 {
                self.lightImage0.drawInRect(rect)
            } else if self.progress < 0.5 {
                self.lightImage25.drawInRect(rect)
            } else if self.progress < 0.75 {
                self.lightImage50.drawInRect(rect)
            } else if self.progress < 1.0 {
                self.lightImage75.drawInRect(rect)
            } else {
                self.lightImage.drawInRect(rect)
            }
        } else {
            if self.progress < 0.25 {
                self.image0.drawInRect(rect)
            } else if self.progress < 0.5 {
                self.image25.drawInRect(rect)
            } else if self.progress < 0.75 {
                self.image50.drawInRect(rect)
            } else if self.progress < 1.0 {
                self.image75.drawInRect(rect)
            } else {
                self.image.drawInRect(rect)
            }
        }
    }

    // MARK: - click handler
    override func mouseDown(theEvent: NSEvent) {
        self.isSelected = !self.isSelected
        self.onMouseDown()
    }

    override func mouseUp(theEvent: NSEvent) {
    }

    override func rightMouseDown(theEvent: NSEvent) {
        self.isSelected = !self.isSelected
        self.onRightMouseDown()
    }

    override func rightMouseUp(theEvent: NSEvent) {
    }

    // MARK: - drag and drop
    override func draggingEntered(sender: NSDraggingInfo) -> NSDragOperation {
        return NSDragOperation.Copy
    }

    override func performDragOperation(sender: NSDraggingInfo) -> Bool {
        let pboard = sender.draggingPasteboard()

        
        if (pboard.types as [String]!).contains(NSFilenamesPboardType) {
            var files:[String] = pboard.propertyListForType(NSFilenamesPboardType) as! [String]
            // TODO: for file ... onDrop
            self.onDrop(files[0])
        }

        return false
    }
}
