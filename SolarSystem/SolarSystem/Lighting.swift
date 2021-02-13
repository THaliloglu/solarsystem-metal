//
//  Lighting.swift
//  SolarSystem
//
//  Created by TOLGA HALILOGLU on 30.01.2021.
//

import Foundation

struct Lighting {
    let sunlight: Light = {
        var light = buildDefaultLight()
        light.position = [0, 1, -2]
        return light
    }()
    
    let ambientLight: Light = {
        var light = buildDefaultLight()
        light.color = [0.5, 1, 0]
        light.intensity = 0.2
        light.type = Ambientlight
        return light
    }()
    
    let redLight: Light = {
        var light = buildDefaultLight()
        light.position = [-1.4, 0, 0]
        light.color = [1, 0, 0]
        light.attenuation = float3(1, 3, 4)
        light.type = Pointlight
        return light
    }()
    
    let spotlight: Light = {
        var light = buildDefaultLight()
        light.position = [1.4, 0, 0]
        light.color = [1, 0, 1]
        light.attenuation = float3(1, 0.5, 0)
        light.type = Spotlight
        light.coneAngle = Float(40).degreesToRadians
        light.coneDirection = [-2, 0, -1.5]
        light.coneAttenuation = 12
        return light
    }()
    
    let lights: [Light]
    let count: UInt32

    static func buildDefaultLight() -> Light {
        var light = Light()
        light.position = [0, 0, 0]
        light.color = [1, 1, 1]
        light.specularColor = [0.6, 0.6, 0.6]
        light.intensity = 1
        light.attenuation = float3(1, 0, 0)
        light.type = Sunlight
        return light
    }
    
    init() {
        lights = [sunlight, ambientLight]
        count = UInt32(lights.count)
    }
}
