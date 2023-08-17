//
//  VectorCalculator.swift
//  VerletSwift
//
//  Created by Alex Popadich on 8/17/23.
//

import Foundation
import CoreGraphics

struct VectorCalculator {
    
    static func vectorAdd(vec_a:CGVector, vec_b:CGVector) -> CGVector {
        let result = CGVectorMake(vec_a.dx + vec_b.dx, vec_a.dy + vec_b.dy)
        return result
    }
    
    static func vectorSubtract(vec_a:CGVector, vec_b:CGVector) -> CGVector {
        let result = CGVectorMake(vec_a.dx - vec_b.dx, vec_a.dy - vec_b.dy)
        return result
    }
    
    static func vectorScale(vec_a:CGVector, scale:CGFloat) -> CGVector {
        let result = CGVectorMake(vec_a.dx * scale, vec_a.dy * scale)
        return result
    }
}
