//
//  Jupiter.swift
//  SolarSystem
//
//  Created by Tolga Haliloglu on 31.01.25.
//

import Foundation

class Jupiter: Model, Planet {
    var solarDay: Float { 1 / (0.41375 * DemoSceneConstants.day) }
    var orbitalPeriod: Float { 1 / (11.86 * DemoSceneConstants.year) }
    var distance: Float { DemoSceneConstants.earthDistance * 5.2 }
    var startAngle: Float = 30
    
    init() {
        super.init(name: "Jupiter.usdz")
        transform.position = [distance, 0, 0]
        transform.scale = DemoSceneConstants.planetScale * 8.8
    }
}
