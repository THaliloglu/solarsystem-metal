//
//  Pluto.swift
//  SolarSystem
//
//  Created by Tolga Haliloglu on 01.02.25.
//

import Foundation

class Pluto: Model, Planet {
    var solarDay: Float { 1 / (6.39 * DemoSceneConstants.day) }
    var orbitalPeriod: Float { 1 / (248.0 * DemoSceneConstants.year) }
    var distance: Float { DemoSceneConstants.earthDistance * 39.48 }
    var startAngle: Float = 320
    
    init() {
        super.init(name: "Pluto.usdz")
        transform.position = [distance, 0, 0]
        transform.scale = DemoSceneConstants.planetScale * 0.15
    }
}
