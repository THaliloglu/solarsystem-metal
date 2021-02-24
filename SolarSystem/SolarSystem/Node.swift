//
//  Node.swift
//  SolarSystem
//
//  Created by TOLGA HALILOGLU on 26.12.2020.
//

import MetalKit

class Node {
    var name: String = "untitled"
    
    var parent: Node?
    var children: [Node] = []
    
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
    
    var worldTransform: float4x4 {
        if let parent = parent {
            return parent.worldTransform * self.modelMatrix
        }
        return modelMatrix
    }
    
    var boundingBox = MDLAxisAlignedBoundingBox()
    var size: float3 {
        return boundingBox.maxBounds - boundingBox.minBounds
    }
    
    func update(deltaTime: Float) {
        // override this
    }
    
    final func add(childNode: Node) {
        children.append(childNode)
        childNode.parent = self
    }
    
    final func remove(childNode: Node) {
        for child in childNode.children {
            child.parent = self
            children.append(child)
        }
        
        childNode.children = []
        guard let index = (children.firstIndex {
            $0 === childNode
        }) else { return }
        
        children.remove(at: index)
        childNode.parent = nil
    }
    
    var forwardVector: float3 {
        return normalize([sin(rotation.y), 0, cos(rotation.y)])
    }
    
    var rightVector: float3 {
        return [forwardVector.z, forwardVector.y, -forwardVector.x]
    }
}
