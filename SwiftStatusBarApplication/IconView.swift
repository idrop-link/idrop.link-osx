//
//  IconView.swift
//  SwiftStatusBarApplication
//
//  Created by Tommy Leung on 6/7/14.
//  Copyright (c) 2014 Christian Schulze, Tommy Leung. All rights reserved.
//

import Foundation
import Cocoa

class IconView : NSView
{
    @IBOutlet var mainMenu: NSMenu?
    
    private(set) var image: NSImage
    private let item: NSStatusItem
    
    var onMouseDown: () -> ()
    var onRightMouseDown: () -> ()
    
    var isSelected: Bool {
        didSet {
            // redraw if isSelected changes for bg highlight
            if (isSelected != oldValue) {
                self.needsDisplay = true
            }
        }
    }
    
    // MARK: - init
    init(imageName: String, item: NSStatusItem) {
        self.image = NSImage(named: imageName)!
        self.item = item
        self.isSelected = false
        self.onMouseDown = {}
        self.onRightMouseDown = {}
        
        let thickness = NSStatusBar.systemStatusBar().thickness
        let rect = CGRectMake(0, 0, thickness, thickness)
        
        super.init(frame: rect)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func drawRect(dirtyRect: NSRect) {
        self.item.drawStatusBarBackgroundInRect(dirtyRect, withHighlight: self.isSelected)
        
        let size = self.image.size
        let rect = CGRectMake(2, 2, size.width, size.height)
        
        self.image.drawInRect(rect)
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
}