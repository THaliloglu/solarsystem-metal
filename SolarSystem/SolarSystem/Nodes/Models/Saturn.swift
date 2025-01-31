//
//  Saturn.swift
//  SolarSystem
//
//  Created by Tolga Haliloglu on 31.01.25.
//

import Foundation

class Saturn: Model, Planet {
    var solarDay: Float { 1 / (0.444 * DemoSceneConstants.day) }
    var orbitalPeriod: Float { 1 / (29.46 * DemoSceneConstants.year) }
    var distance: Float { DemoSceneConstants.earthDistance * 9.58 }
    var startAngle: Float = 140
    
    init() {
        super.init(name: "Saturn.usdz")
        transform.position = [distance, 0, 0]
        transform.scale = DemoSceneConstants.planetScale * 7.3
    }
}
