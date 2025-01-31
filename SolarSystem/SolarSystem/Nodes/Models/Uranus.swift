//
//  Uranus.swift
//  SolarSystem
//
//  Created by Tolga Haliloglu on 31.01.25.
//

import Foundation

class Uranus: Model, Planet {
    var solarDay: Float { 1 / (0.718 * DemoSceneConstants.day) }
    var orbitalPeriod: Float { 1 / (84.02 * DemoSceneConstants.year) }
    var distance: Float { DemoSceneConstants.earthDistance * 19.22 }
    var startAngle: Float = 210
    
    init() {
        super.init(name: "Uranus.usdz")
        transform.position = [distance, 0, 0]
        transform.scale = DemoSceneConstants.planetScale * 3.2
    }
}
