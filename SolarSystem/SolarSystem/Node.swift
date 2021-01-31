//
//  Node.swift
//  SolarSystem
//
//  Created by TOLGA HALILOGLU on 26.12.2020.
//

import MetalKit

class Node {
    var name: String = "untitled"
    
    var position: float3 = [0, 0, 0]
    
    var quaternion = simd_quatf()
    var rotation: float3 = [0, 0, 0] {
        didSet {
            let rotationMatrix = float4x4(rotation: rotation)
            quaternion = simd_quatf(rotationMatrix)
        }
    }
    
    var scale: float3 = [1, 1, 1]
    
    var modelMatrix: float4x4 {
        let translateMatrix = float4x4(translation: position)
        let rotateMatrix = float4x4(quaternion)
        let scaleMatrix = float4x4(scaling: scale)
        return translateMatrix * rotateMatrix * scaleMatrix
    }
    
    var boundingBox = MDLAxisAlignedBoundingBox()
    var size: float3 {
        return boundingBox.maxBounds - boundingBox.minBounds
    }
    
    func update(deltaTime: Float) {
        // override this
    }
}
