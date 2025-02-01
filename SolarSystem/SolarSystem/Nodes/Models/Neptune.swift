//
//  Neptune.swift
//  SolarSystem
//
//  Created by Tolga Haliloglu on 01.02.25.
//

import Foundation

class Neptune: Model, Planet {
    var solarDay: Float { 1 / (0.671 * DemoSceneConstants.day) }
    var orbitalPeriod: Float { 1 / (164.8 * DemoSceneConstants.year) }
    var distance: Float { DemoSceneConstants.earthDistance * 30.07 }
    var startAngle: Float = 280
    
    init() {
        super.init(name: "Neptune.usdz")
        transform.position = [distance, 0, 0]
        transform.scale = DemoSceneConstants.planetScale * 3.1
    }
}
