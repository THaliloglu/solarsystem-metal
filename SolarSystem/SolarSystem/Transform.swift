//
//  Transform.swift
//  SolarSystem
//
//  Created by TOLGA HALILOGLU on 5.05.2021.
//

import Foundation

struct Transform {
    var position: float3 = [0, 0, 0]
    var rotation: float3 = [0, 0, 0]
    var scale: float3 = [1, 1, 1]
    var modelMatrix: float4x4 {
        let translateMatrix = float4x4(translation: position)
        let rotateMatrix = float4x4(rotation: rotation)
        let scaleMatrix = float4x4(scaling: scale)
        return translateMatrix * rotateMatrix * scaleMatrix
    }
    var normalMatrix: float3x3 {
        return float3x3(normalFrom4x4: modelMatrix)
    }
}
