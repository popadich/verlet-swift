//
//  Particle.swift
//  VerletSwift
//
//  Created by Alex Popadich on 8/17/23.
//

import Foundation
import CoreGraphics

class Particle: NSObject {
    var radius: CGFloat
    var position_last: CGVector
    var position: CGVector
    var acceleration: CGVector
    var color: CGColor
    
    init(radius: CGFloat, position: CGVector, color: CGColor?) {
        self.radius = radius
        self.position_last = position
        self.position = position
        self.acceleration = CGVector(dx: 0.0, dy: 0.0)
        self.color = color ?? CGColor.white
    }
    
        
    func update(_ dt:CGFloat) {
        let pos = position
        let pos_last = position_last
        
        // Compute how much we moved
        let displacement = VectorCalculator.vectorSubtract(vec_a: pos, vec_b: pos_last)
        
        // Update position
        position_last = position
        let positionDisplaced = VectorCalculator.vectorAdd(vec_a: pos, vec_b: displacement)
        let accelerated = VectorCalculator.vectorScale(vec_a: acceleration, scale: dt*dt)
        position = VectorCalculator.vectorAdd(vec_a: positionDisplaced, vec_b: accelerated)
        
        // Reset acceleration
        acceleration = CGVector.zero
    }

    func accelerate(_ acc: CGVector) {
        acceleration = VectorCalculator.vectorAdd(vec_a: acceleration, vec_b: acc);
    }
    
    func setVelocity(_ v: CGVector, forDelta dt: CGFloat) {
        let dv: CGVector = VectorCalculator.vectorScale(vec_a: v, scale: dt)
        position_last = VectorCalculator.vectorSubtract(vec_a: position, vec_b: dv)
    }
    
    func addVelocity(_ v: CGVector, forDelta dt: CGFloat) {
        let dv: CGVector = VectorCalculator.vectorScale(vec_a: v, scale: dt)
        position_last = VectorCalculator.vectorSubtract(vec_a: position_last, vec_b: dv)
    }
    
    func getVelocity(forDelta dt: CGFloat) -> CGVector {
        var velocity = VectorCalculator.vectorSubtract(vec_a: position, vec_b: position_last)
        velocity = VectorCalculator.vectorScale(vec_a: velocity, scale: 1/dt)
        return velocity
    }
}
