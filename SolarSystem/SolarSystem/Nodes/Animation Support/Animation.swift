//
//  Animation.swift
//  SolarSystem
//
//  Created by TOLGA HALILOGLU on 31.01.2021.
//

import Foundation

struct KeyQuaternion {
    var time: Float = 0
    var value: simd_quatf = .identity
}

struct Keyframe {
    var time: Float = 0
    var value: float3 = [0, 0, 0]
}

struct Animation {
    var translations: [Keyframe] = []
    var repeatAnimation = true
    var rotations: [KeyQuaternion] = []
    
    func getTranslation(at time: Float) -> float3? {
        guard let lastKeyframe = translations.last else {
            return nil
        }
        
        var currentTime = time
        
        // is first
        if let first = translations.first, first.time >= currentTime {
            return first.value
        }
        
        // is last
        if currentTime >= lastKeyframe.time, !repeatAnimation {
            return lastKeyframe.value
        }
        
        // main proccess
        currentTime = fmod(currentTime, lastKeyframe.time)
        let keyFramePairs = translations.indices.dropFirst().map {
            (previous: translations[$0 - 1], next: translations[$0])
        }
        
        guard let (previousKey, nextKey) = ( keyFramePairs.first { currentTime < $0.next.time }) else {
            return nil
        }
        
        let interpolant = (currentTime - previousKey.time) / (nextKey.time - previousKey.time)
        
        // Use the simd_mix function to interpolate between the two keyframes.
        return simd_mix(previousKey.value, nextKey.value, float3(repeating: interpolant))
    }
    
    func getRotation(at time: Float) -> simd_quatf? {
        guard let lastKeyframe = rotations.last else {
            return nil
        }
        
        var currentTime = time
        
        // is first
        if let first = rotations.first, first.time >= currentTime {
            return first.value
        }
        
        // is last
        if currentTime >= lastKeyframe.time, !repeatAnimation {
            return lastKeyframe.value
        }
        
        // main proccess
        currentTime = fmod(currentTime, lastKeyframe.time)
        let keyFramePairs = rotations.indices.dropFirst().map {
            (previous: rotations[$0 - 1], next: rotations[$0])
        }
        guard let (previousKey, nextKey) = ( keyFramePairs.first {
            currentTime < $0.next.time
        })
        else { return nil }
        
        let interpolant = (currentTime - previousKey.time) / (nextKey.time - previousKey.time)
        
        // This does the necessary spherical interpolation.
        return simd_slerp(previousKey.value, nextKey.value, interpolant)
    }
}
