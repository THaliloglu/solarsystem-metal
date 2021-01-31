//
//  SphereAnimations.swift
//  SolarSystem
//
//  Created by TOLGA HALILOGLU on 31.01.2021.
//

import MetalKit

// Keyframe Example Positions
func generateSphereTranslations() -> [Keyframe] {
    return [
        Keyframe(time: 0,    value: [ 2, 0, 0]),
        Keyframe(time: 0.25, value: [1.5,0,1.5]),
        Keyframe(time: 0.5, value: [ 0, 0, 2]),
        Keyframe(time: 0.75, value: [-1.5, 0,1.5]),
        Keyframe(time: 1.0,  value: [-2, 0, 0]),
        Keyframe(time: 1.25, value: [-1.5, 0,-1.5]),
        Keyframe(time: 1.5, value: [ 0, 0, -2]),
        Keyframe(time: 1.75, value: [1.5, 0, -1.5]),
        Keyframe(time: 2,    value: [ 2, 0, 0])
    ]
}

// Keyframe Example Rotations
func generateSphereRotations() -> [KeyQuaternion] {
  return [
    KeyQuaternion(time: 0,    value: simd_quatf(ix: 0, iy: 0, iz: 0, r: 1)),
    KeyQuaternion(time: 0.08, value: simd_quatf(angle: .pi/2, axis: [0, -1, 0])),
    KeyQuaternion(time: 0.17, value: simd_quatf(angle: .pi, axis: [0, -1, 0])),
    KeyQuaternion(time: 0.26, value: simd_quatf(angle: .pi + .pi/2, axis: [0, -1, 0])),
    KeyQuaternion(time: 0.35, value: simd_quatf(angle: 0, axis: [0, -1, 0])),
    KeyQuaternion(time: 1.0,  value: simd_quatf(angle: 0, axis: [0, -1, 0])),
    KeyQuaternion(time: 1.08, value: simd_quatf(angle: .pi + .pi/2, axis: [0, -1, 0])),
    KeyQuaternion(time: 1.17, value: simd_quatf(angle: .pi, axis: [0, -1, 0])),
    KeyQuaternion(time: 1.26, value: simd_quatf(angle: .pi/2, axis: [0, -1, 0])),
    KeyQuaternion(time: 1.35, value: simd_quatf(ix: 0, iy: 0, iz: 0, r: 1)),
    KeyQuaternion(time: 2,    value: simd_quatf(ix: 0, iy: 0, iz: 0, r: 1))
  ]
}
