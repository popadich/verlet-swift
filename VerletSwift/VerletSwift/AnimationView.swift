//
//  AnimationView.swift
//  VerletSwift
//
//  Created by Alex Popadich on 8/17/23.
//

import Cocoa


class AnimationView: NSView {
    var particlesArray : Array<Particle>?
    private var constraintRect : CGRect = CGRect.zero
    private let backgroundColor : CGColor = CGColor(gray: 0.5, alpha: 1.0)
    private let constraintColor : CGColor = CGColor.black
        

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
        if let context: CGContext = NSGraphicsContext.current?.cgContext {
            
            context.setFillColor(backgroundColor)
            context.fill(bounds)
            
            context.setFillColor(constraintColor)
            context.fillEllipse(in: constraintRect)
            
            if let particles = particlesArray {
                for particle in particles {
                    context.setFillColor(particle.color)
                    let radius = particle.radius
                    let rect = CGRectMake(particle.position.dx - radius, particle.position.dy - radius, radius*2, radius*2)
                    context.fillEllipse(in: rect)
                }
            }
        }
    }
    
    func setConstraint(position: CGPoint, withRadius radius: CGFloat) {
        constraintRect = CGRectMake(position.x, position.y, radius*2, radius*2)
        constraintRect = CGRectOffset(constraintRect, -radius, -radius)
    }

}
