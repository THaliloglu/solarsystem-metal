//
//  Mars.swift
//  SolarSystem
//
//  Created by Tolga Haliloğlu on 26.10.23.
//

import Foundation

class Mars: Model, Planet {
    var solarDay: Float { 1 / (1.04 * DemoSceneConstants.day) }
    var orbitalPeriod: Float { 1 / (1.9 * DemoSceneConstants.year) }
    var distance: Float { DemoSceneConstants.earthDistance * 1.5 }
    var startAngle: Float = 30
    
    init() {
        super.init(name: "mars.obj")
        transform.position = [distance, 0, 0]
        transform.scale = DemoSceneConstants.planetScale * 0.5
    }
}
