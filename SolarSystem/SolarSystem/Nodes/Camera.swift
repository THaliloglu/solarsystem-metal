//
//  Camera.swift
//  SolarSystem
//
//  Created by TOLGA HALILOGLU on 26.12.2020.
//

import Foundation

class Camera: Node {
    
    var fovDegrees: Float = 45
    var fovRadians: Float {
        return fovDegrees.degreesToRadians
    }
    var aspect: Float = 1
    var near: Float = 0.001
    var far: Float = 100
    
    var projectionMatrix: float4x4 {
        return float4x4(projectionFov: fovRadians,
                        near: near,
                        far: far,
                        aspect: aspect)
    }
    
    var viewMatrix: float4x4 {
        let translateMatrix = float4x4(translation: position)
        let rotateMatrix = float4x4(rotation: rotation)
        let scaleMatrix = float4x4(scaling: scale)
        return (translateMatrix * scaleMatrix * rotateMatrix).inverse
    }
    
    func zoom(delta: Float) {}
    func rotate(delta: float2) {}
}


class ArcballCamera: Camera {
    
    var minDistance: Float = 0.5
    var maxDistance: Float = 10
    var target: float3 = [0, 0, 0] {
        didSet {
            _viewMatrix = updateViewMatrix()
        }
    }
    
    var distance: Float = 0 {
        didSet {
            _viewMatrix = updateViewMatrix()
        }
    }
    
    override var rotation: float3 {
        didSet {
            _viewMatrix = updateViewMatrix()
        }
    }
    
    override var viewMatrix: float4x4 {
        return _viewMatrix
    }
    private var _viewMatrix = float4x4.identity()
    
    override init() {
        super.init()
        _viewMatrix = updateViewMatrix()
    }
    
    private func updateViewMatrix() -> float4x4 {
        let translateMatrix = float4x4(translation: [target.x, target.y, target.z - distance])
        let rotateMatrix = float4x4(rotationYXZ: [-rotation.x,
                                                  rotation.y,
                                                  0])
        let matrix = (rotateMatrix * translateMatrix).inverse
        position = rotateMatrix.upperLeft * -matrix.columns.3.xyz
        return matrix
    }
    
    override func zoom(delta: Float) {
        let sensitivity: Float = 0.05
        distance -= delta * sensitivity
        _viewMatrix = updateViewMatrix()
    }
    
    override func rotate(delta: float2) {
        let sensitivity: Float = 0.005
        
        let y = rotation.y + delta.x * sensitivity
        
        var x = rotation.x + delta.y * sensitivity
        x = max(-Float.pi/2, min((x), Float.pi/2))
        
        let z = rotation.z
        rotation = [x, y, z]
        
        _viewMatrix = updateViewMatrix()
    }
}

class OrthographicCamera: Camera {
    var rect = Rectangle(left: 10, right: 10,
                         top: 10, bottom: 10)
    override init() {
        super.init()
    }
    
    init(rect: Rectangle, near: Float, far: Float) {
        super.init()
        self.rect = rect
        self.near = near
        self.far = far
    }
    
    override var projectionMatrix: float4x4 {
        return float4x4(orthographic: rect, near: near, far: far)
    }
}

class ThirdPersonCamera: Camera {
    var focus: Node
    var focusDistance: Float = 5
    var focusHeight: Float = 1.2
    
    init(focus: Node) {
        self.focus = focus
        super.init()
    }
    
    override var viewMatrix: float4x4 {
        position = focus.position - focusDistance * focus.forwardVector
        position.y = focusHeight
        rotation.y = focus.rotation.y
        return super.viewMatrix
    }
}
