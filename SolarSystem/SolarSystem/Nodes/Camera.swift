//
//  Camera.swift
//  SolarSystem
//
//  Created by TOLGA HALILOGLU on 26.12.2020.
//

import Foundation

protocol Camera: Transformable {
    var projectionMatrix: float4x4 { get }
    var viewMatrix: float4x4 { get }
    func update(size: CGSize)
    func update(deltaTime: Float)
}

class ArcballCamera: Camera {
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
    
    let minDistance: Float = 0.0
    let maxDistance: Float = 20
    var target: float3 = [0, 0, 0]
    var distance: Float = 2.5
    
    func update(size: CGSize) {
        aspect = Float(size.width / size.height)
    }
    
    var viewMatrix: float4x4 {
        let matrix: float4x4
        if target == position {
            matrix = (float4x4(translation: target) * float4x4(rotationYXZ: rotation)).inverse
        } else {
            matrix = float4x4(eye: position, center: target, up: [0, 1, 0])
        }
        return matrix
    }
    
    func update(deltaTime: Float) {
        let input = InputController.shared
        let scrollSensitivity = Settings.mouseScrollSensitivity
        distance -= (input.mouseScroll.x + input.mouseScroll.y)
        * scrollSensitivity
        distance = min(maxDistance, distance)
        distance = max(minDistance, distance)
        input.mouseScroll = .zero
        if input.leftMouseDown {
            let sensitivity = Settings.mousePanSensitivity
            self.transform.rotation.x += input.mouseDelta.y * sensitivity
            self.transform.rotation.y += input.mouseDelta.x * sensitivity
            self.transform.rotation.x = max(-.pi / 2, min(rotation.x, .pi / 2))
            input.mouseDelta = .zero
        }
        let rotateMatrix = float4x4(
            rotationYXZ: [-rotation.x, rotation.y, 0])
        let distanceVector = float4(0, 0, -distance, 0)
        let rotatedVector = rotateMatrix * distanceVector
        self.transform.position = target + rotatedVector.xyz
    }
}


class OrthographicCamera: Camera, Movement {
    var transform = Transform()
    var aspect: CGFloat = 1
    var viewSize: CGFloat = 10
    var near: Float = 0.1
    var far: Float = 100
    
    var viewMatrix: float4x4 {
        (float4x4(translation: position) *
         float4x4(rotation: rotation)).inverse
    }
    
    var projectionMatrix: float4x4 {
        let rect = CGRect(
            x: -viewSize * aspect * 0.5,
            y: viewSize * 0.5,
            width: viewSize * aspect,
            height: viewSize)
        return float4x4(orthographic: rect, near: near, far: far)
    }
    
    func update(size: CGSize) {
        aspect = size.width / size.height
        
//        Need to check
//        Old code from DEMO SCENE source
//
//        let cameraSize: Float = 10
//        let ratio = Float(sceneSize.width / sceneSize.height)
//        let rect = Rectangle(left: -cameraSize * ratio,
//                             right: cameraSize * ratio,
//                             top: cameraSize,
//                             bottom: -cameraSize)
//        orthoCamera.rect = rect
    }
    
    func update(deltaTime: Float) {
        let transform = updateInput(deltaTime: deltaTime)
        self.transform.position = transform.position
        let input = InputController.shared
        let zoom = input.mouseScroll.x + input.mouseScroll.y
        viewSize -= CGFloat(zoom)
        input.mouseScroll = .zero
    }
}

class TPCamera: Camera {
    var focus: Movement
    var focusDistance: Float = 5
    var focusHeight: Float = 1.2
    
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
    
    init(focus: Movement) {
        self.focus = focus
    }
    
    var viewMatrix: float4x4 {
        var position = focus.position - focusDistance * focus.forwardVector
        position.y = focusHeight
        var rotation = rotation
        rotation.y = focus.rotation.y
        
        return (float4x4(translation: position) * float4x4(rotation: rotation)).inverse
    }
    
    func update(size: CGSize) {
        aspect = Float(size.width / size.height)
    }
    
    func update(deltaTime: Float) {
        
    }
    
}

class FPCamera: Camera {
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
    
    var viewMatrix: float4x4 {
        (float4x4(translation: position) *
         float4x4(rotation: rotation)).inverse
    }
    
    func update(size: CGSize) {
        aspect = Float(size.width / size.height)
    }
    
    func update(deltaTime: Float) {
        let transform = updateInput(deltaTime: deltaTime)
        self.transform.rotation += transform.rotation
        self.transform.position += transform.position
    }
}

extension FPCamera: Movement { }
