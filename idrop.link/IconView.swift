//
//  IconView.swift
//  idrop.link
//
//  Created by Tommy Leung on 6/7/14.
//  Copyright (c) 2014 Christian Schulze, Tommy Leung. All rights reserved.
//

import Foundation
import Cocoa

class IconView : NSView, NSDraggingDestination {
    @IBOutlet var mainMenu: NSMenu?
    
    private(set) var lightImage: NSImage
    private(set) var image: NSImage
    private let item: NSStatusItem
    
    var onMouseDown: () -> ()
    var onRightMouseDown: () -> ()
    var onDrop: (String) -> ()
    
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
        self.lightImage = NSImage(named: "iconlight")!
        
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
            self.lightImage.drawInRect(rect)
        } else {
            self.image.drawInRect(rect)
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
    
    // MARK: - drag and drop
    override func draggingEntered(sender: NSDraggingInfo) -> NSDragOperation {
        return NSDragOperation.Copy
    }
    
    override func performDragOperation(sender: NSDraggingInfo) -> Bool {
        var pboard = sender.draggingPasteboard()
        
        if pboard != nil {
            if contains(pboard.types as! [NSString], NSFilenamesPboardType) {
                var files:[String] = pboard.propertyListForType(NSFilenamesPboardType) as! [String]
                // TODO: for file ... onDrop
                self.onDrop(files[0])
            }
            return true
        }
        
        return false
    }
}