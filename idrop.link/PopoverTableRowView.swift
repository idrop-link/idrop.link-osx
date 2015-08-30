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
            var selectionRect = NSInsetRect(self.bounds, 5.5, 5.5)

            NSColor(calibratedWhite: 0.72, alpha: 1.0).setStroke()
            NSColor(calibratedWhite: 0.82, alpha: 1.0).setFill()

            var selectionPath = NSBezierPath(roundedRect: selectionRect,
                xRadius: 4,
                yRadius: 4)

            selectionPath.fill()
            selectionPath.stroke()
        }
    }

    func gradientWithTargetColor(color: NSColor) -> NSGradient {
        var colors =  [color.colorWithAlphaComponent(0.0),
            color,
            color,
            color.colorWithAlphaComponent(0.0)]

        var locations: [CGFloat] = [ 0.0, 0.35, 0.65, 1.0 ]

        return NSGradient(colors: colors,
            atLocations: locations,
            colorSpace: NSColorSpace.sRGBColorSpace())
    }

    override func drawSeparatorInRect(dirtyRect: NSRect) {
        var gradient = gradientWithTargetColor(NSColor(SRGBRed: 0.80,
            green: 0.80,
            blue: 0.80,
            alpha: 1.0))

        var sepRect = self.bounds
        sepRect.origin.y = NSMaxY(sepRect) - 1
        sepRect.size.height = 1
        
        gradient.drawInRect(sepRect, angle: 0)
    }

}
