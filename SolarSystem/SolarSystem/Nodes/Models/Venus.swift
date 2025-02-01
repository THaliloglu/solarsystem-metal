//
//  Venus.swift
//  SolarSystem
//
//  Created by Tolga Haliloğlu on 26.10.23.
//

import Foundation

class Venus: Model, Planet {
    var solarDay: Float { 1 / (243 * DemoSceneConstants.day) }
    var orbitalPeriod: Float { 1 / (0.6 * DemoSceneConstants.year) }
    var distance: Float { DemoSceneConstants.earthDistance * 0.7 }
    var startAngle: Float = 20
    
    init() {
        super.init(name: "venus.obj")
        transform.position = [distance, 0, 0]
        transform.scale = DemoSceneConstants.planetScale * 0.95
    }
}
