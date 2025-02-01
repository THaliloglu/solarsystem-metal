//
//  Mercury.swift
//  SolarSystem
//
//  Created by Tolga Haliloğlu on 26.10.23.
//

import Foundation

class Mercury: Model, Planet {
    var solarDay: Float { 1 / (58 * DemoSceneConstants.day) }
    var orbitalPeriod: Float { 1 / (0.2 * DemoSceneConstants.year) }
    var distance: Float { DemoSceneConstants.earthDistance * 0.4 }
    var startAngle: Float = 10
    
    init() {
        super.init(name: "mercury.obj")
        transform.position = [distance, 0, 0]
        transform.scale = DemoSceneConstants.planetScale * 0.3
    }
}
