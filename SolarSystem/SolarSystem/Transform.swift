//
//  Transform.swift
//  SolarSystem
//
//  Created by TOLGA HALILOGLU on 5.05.2021.
//

import Foundation

//struct Transform {
//    var position: float3 = [0, 0, 0]
//    var rotation: float3 = [0, 0, 0]
//    var scale: float3 = [1, 1, 1]
//    var modelMatrix: float4x4 {
//        let translateMatrix = float4x4(translation: position)
//        let rotateMatrix = float4x4(rotation: rotation)
//        let scaleMatrix = float4x4(scaling: scale)
//        return translateMatrix * rotateMatrix * scaleMatrix
//    }
//    var normalMatrix: float3x3 {
//        return float3x3(normalFrom4x4: modelMatrix)
//    }
//}

//struct Transform {
//    var position: float3 = [0, 0, 0]
//    var rotation: float3 = [0, 0, 0]
//    var scale: Float = 1
//}
//
//extension Transform {
//    var modelMatrix: matrix_float4x4 {
//        let translation = float4x4(translation: position)
//        let rotation = float4x4(rotation: rotation)
//        let scale = float4x4(scaling: scale)
//        let modelMatrix = translation * rotation * scale
//        return modelMatrix
//    }
//    var normalMatrix: float3x3 {
//        return float3x3(normalFrom4x4: modelMatrix)
//    }
//
//}
//
//protocol Transformable {
//    var transform: Transform { get set }
//}
//
//extension Transformable {
//    var position: float3 {
//        get { transform.position }
//        set { transform.position = newValue }
//    }
//    var rotation: float3 {
//        get { transform.rotation }
//        set { transform.rotation = newValue }
//    }
//    var scale: Float {
//        get { transform.scale }
//        set { transform.scale = newValue }
//    }
//}

class Transform {
    var position: float3 = [0, 0, 0]
    var rotation: float3 = [0, 0, 0] {
        didSet {
            let rotationMatrix = float4x4(rotation: rotation)
            quaternion = simd_quatf(rotationMatrix)
        }
    }
    var scale: Float = 1
    var quaternion: simd_quatf = .identity
}

extension Transform {
    var modelMatrix: matrix_float4x4 {
        let translation = float4x4(translation: position)
        let rotation = float4x4(quaternion)
        let scale = float4x4(scaling: scale)
        let modelMatrix = translation * rotation * scale
        return modelMatrix
    }
    var normalMatrix: float3x3 {
        return float3x3(normalFrom4x4: modelMatrix)
    }
}

protocol Transformable {
    var transform: Transform { get set }
}

extension Transformable {
    var position: float3 {
        get { transform.position }
        set { transform.position = newValue }
    }
    var rotation: float3 {
        get { transform.rotation }
        set { transform.rotation = newValue }
    }
    var scale: Float {
        get { transform.scale }
        set { transform.scale = newValue }
    }
    var quaternion: simd_quatf {
        get { transform.quaternion }
        set { transform.quaternion = newValue }
    }
}
