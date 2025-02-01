//
//  PlayerCamera.swift
//  SolarSystem
//
//  Created by Tolga Haliloğlu on 18.05.24.
//

import Foundation

class PlayerCamera: Camera {
    var transform = Transform()
    var aspect: Float = 1.0
    var fov = Float(70).degreesToRadians
    var near: Float = 0.1
    var far: Float = 100
    var projectionMatrix: float4x4 {
        float4x4(
            projectionFov: fov,
            near: near,
            far: far,
            aspect: aspect)
    }
    
    func update(size: CGSize) {
        aspect = Float(size.width / size.height)
    }
    
    var viewMatrix: float4x4 {
        let rotateMatrix = float4x4(
            rotationYXZ: [-rotation.x, rotation.y, 0])
        return (float4x4(translation: position) * rotateMatrix).inverse
    }
    
    func update(deltaTime: Float) {
        let transform = updateInput(deltaTime: deltaTime)
        self.transform.rotation += transform.rotation
        self.transform.position += transform.position
        let input = InputController.shared
        if input.leftMouseDown && input.isResizing == false {
            let sensitivity = Settings.mousePanSensitivity
            self.transform.rotation.x += input.mouseDelta.y * sensitivity
            self.transform.rotation.y += input.mouseDelta.x * sensitivity
            self.transform.rotation.x = max(-.pi / 2, min(rotation.x, .pi / 2))
            input.mouseDelta = .zero
        }
        
    }
}

extension PlayerCamera: Movement { }
