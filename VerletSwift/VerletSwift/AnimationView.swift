//
//  AnimationView.swift
//  VerletSwift
//
//  Created by Alex Popadich on 8/17/23.
//

import Cocoa


class AnimationView: NSView {
    private let backgroundColor : CGColor = CGColor(gray: 0.5, alpha: 1.0)

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
        if let context: CGContext = NSGraphicsContext.current?.cgContext {
            context.setFillColor(backgroundColor)
            context.fill(bounds)
        }
    }
    
}
