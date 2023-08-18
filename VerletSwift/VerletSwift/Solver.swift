//
//  Solver.swift
//  VerletSwift
//
//  Created by Alex Popadich on 8/11/23.
//

import Foundation
import CoreGraphics

protocol SolverProtocol: AnyObject {
    func updateAnimationView(_ solver: Solver)
    func animationHasFinished(_ solver: Solver)
}

class Solver: NSObject {
    weak var delegate: SolverProtocol? = nil
    var simulationTimer: Timer? = nil

    var particlesArray = Array<Particle>()
    var m_constraint_center : CGPoint = CGPoint.zero
    var m_constraint_radius : CGFloat = 0.0
    
    var m_sub_steps : Int = 1
    var m_gravity : CGVector = CGVectorMake(0.0, -1000.0)
    var m_time : CGFloat = 0.0
    var m_frame_dt : CGFloat = 0.0

    
    init(withParticleCount particleCount : Int) {
        
        for _ in 0..<particleCount {
            let x = CGFloat.random(in: 20.0..<200.0)
            let y = CGFloat.random(in: 200.0..<400.0)
            
            let pos = CGVectorMake(x, y)
            let particle = Particle(radius: 10.0, position: pos, color: nil)
            self.particlesArray.append(particle)
        }
        
    }
    
    func getRainbow(forTime t: CGFloat) -> CGColor {
        let r = sin(t)
        let g = sin(t + 0.33 * 2.0 * CGFloat.pi)
        let b = sin(t + 0.66 * 2.0 * CGFloat.pi)
        
        let color = CGColor(red: r*r, green: g*g, blue: b*b, alpha: 1.0)
        return color
    }

    func addParticle(position: CGVector, withRadius radius : CGFloat) -> Particle {
        let aParticle : Particle = Particle(radius: radius, position: position, color: getRainbow(forTime: getTime()))
        particlesArray.append(aParticle)
        return aParticle
    }
    
    func update() {
        m_time += m_frame_dt
        
        let step_dt = getStepDt()
        for _ in 0..<m_sub_steps {
            applyGravity()
            checkCollisions(forDelta: step_dt)
            applyConstraint()
            updateObjects(forDelta: step_dt)
        }

        delegate?.updateAnimationView(self)
    }
    
    func setSimulationUpdateRate(_ rate: Int) {
        m_frame_dt = 1.0/CGFloat(rate)
    }
    
    func setSubStepsCount(_ sub_steps : Int) {
        m_sub_steps = sub_steps
    }
    
    func setObjectVelocity(object : Particle, velocity : CGVector) {
        object.setVelocity(velocity, forDelta: getStepDt())
    }
    
    
    func setConstraint(position: CGPoint, withRadius radius: CGFloat) {
        m_constraint_center = position
        m_constraint_radius = radius
    }
        
    func getTime() -> CGFloat {
        return m_time
    }
    
    func getStepDt() -> CGFloat {
        return m_frame_dt / CGFloat(m_sub_steps)
    }
    
    func applyGravity() {
        for particle in particlesArray {
            particle.accelerate(m_gravity)
        }
    }
    
    func applyConstraint() {
        for particle in particlesArray {
            let v = CGVector(dx: m_constraint_center.x - particle.position.dx, dy: m_constraint_center.y - particle.position.dy)
            let dist = sqrt(v.dx*v.dx + v.dy*v.dy)
            if dist > (m_constraint_radius - particle.radius) {
                let n : CGVector = CGVectorMake(v.dx/dist, v.dy/dist)
                particle.position = CGVectorMake(m_constraint_center.x - n.dx * (m_constraint_radius - particle.radius), m_constraint_center.y - n.dy * (m_constraint_radius - particle.radius))
            }
        }
    }
    
    func checkCollisions(forDelta dt: CGFloat) {
        let response_coef = 0.75
        
        let objectCount = particlesArray.count
        for i : Int in 0..<objectCount {
            let object_1 : Particle = particlesArray[i]
            
            for k : Int in i+1..<objectCount {
                let object_2 : Particle = particlesArray[k]
                
                let v = VectorCalculator.vectorSubtract(vec_a: object_1.position, vec_b: object_2.position)
                let dist2 = (v.dx * v.dx) + (v.dy * v.dy)
                let min_dist = object_1.radius + object_2.radius

                // Check overlap
                if dist2 < (min_dist * min_dist) {
                    let dist : CGFloat = sqrt(dist2)
                    let n = CGVector(dx: v.dx/dist, dy: v.dy/dist)
                    let mass_ratio_1 = object_1.radius / (object_1.radius + object_2.radius)
                    let mass_ratio_2 = object_2.radius / (object_1.radius + object_2.radius)
                    let delta        = 0.5 * response_coef * (dist - min_dist)

                    // Update positions
                    let p1 = object_1.position
                    let p2 = object_2.position
                    
                    object_1.position = CGVectorMake(p1.dx - n.dx * (mass_ratio_2 * delta), p1.dy - n.dy * (mass_ratio_2 * delta))
                    object_2.position = CGVectorMake(p2.dx + n.dx * (mass_ratio_1 * delta), p2.dy + n.dy * (mass_ratio_1 * delta))
                }
            }
        }
    }

    
    func updateObjects(forDelta dt : CGFloat) {
        for particle in particlesArray {
            particle.update(dt)
        }
    }

    // ACTIVITY METHODS
    
    func startAnimation() {
        simulationTimer = Timer.scheduledTimer(withTimeInterval: m_frame_dt, repeats: true) { timer in
            self.update()
        }
    }
    
    func stopAnimation() {
        simulationTimer?.invalidate()
        simulationTimer = nil
    }
    
    func resetAnimation() {
        particlesArray.removeAll()
        m_time = 0.0
        update()
    }

}
