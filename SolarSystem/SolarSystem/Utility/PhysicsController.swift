//
//  PhysicsController.swift
//  SolarSystem
//
//  Created by TOLGA HALILOGLU on 17.03.2021.
//

import MetalKit

// Render bounding boxes
var debugRenderBoundingBox = false
class PhysicsController {
    
    var dynamicBody: Node?
    var staticBodies: [Node] = []
    
    func addStaticBody(node: Node) {
        removeBody(node: node)
        staticBodies.append(node)
    }
    
    func removeBody(node: Node) {
        if let index = staticBodies.firstIndex(where: {
            $0.self === node
        }) {
            staticBodies.remove(at: index)
        }
    }
    
    func checkCollisions() -> Bool {
        guard let node = dynamicBody else { return false }
        let nodeRadius = max((node.size.x / 2), (node.size.z / 2))
        let nodePosition = node.worldTransform.columns.3.xyz
        for body in staticBodies  {
            let bodyRadius = max((body.size.x / 2), (body.size.z / 2))
            let bodyPosition = body.worldTransform.columns.3.xyz
            let d = distance(nodePosition, bodyPosition)
            if d < (nodeRadius + bodyRadius) {
                // There's a hit
                return true
            }
        }
        return false
    }
}
