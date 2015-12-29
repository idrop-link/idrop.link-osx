//
//  PopoverTableRowView.swift
//  idrop.link
//
//  Created by Christian Schulze on 01/06/15.
//  Copyright (c) 2015 andinfinity. All rights reserved.
//

import Cocoa

class PopoverTableRowView: NSTableRowView {

    override func drawSelectionInRect(dirtyRect: NSRect) {
        if self.selectionHighlightStyle != NSTableViewSelectionHighlightStyle.None {
            let selectionRect = NSInsetRect(self.bounds, 5.5, 5.5)

            NSColor(calibratedWhite: 0.72, alpha: 1.0).setStroke()
            NSColor(calibratedWhite: 0.82, alpha: 1.0).setFill()
            
            let selectionPath = NSBezierPath(roundedRect: selectionRect, xRadius: 4, yRadius: 4)

            selectionPath.fill()
            selectionPath.stroke()
        }
    }

    func gradientWithTargetColor(color: NSColor) -> NSGradient {
        let colors =  [color.colorWithAlphaComponent(0.0),
            color,
            color,
            color.colorWithAlphaComponent(0.0)]

        let locations: [CGFloat] = [ 0.0, 0.35, 0.65, 1.0 ]

        return NSGradient(colors: colors, atLocations: locations, colorSpace: NSColorSpace.sRGBColorSpace())!
    }

    override func drawSeparatorInRect(dirtyRect: NSRect) {
        let gradient = gradientWithTargetColor(NSColor(SRGBRed: 0.80, green: 0.80, blue: 0.80, alpha: 1.0))
        
        var sepRect = self.bounds
        sepRect.origin.y = NSMaxY(sepRect) - 1
        sepRect.size.height = 1
        
        gradient.drawInRect(sepRect, angle: 0)
    }

}
