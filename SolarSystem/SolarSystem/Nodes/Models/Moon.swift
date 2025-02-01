//
//  Moon.swift
//  SolarSystem
//
//  Created by Tolga Haliloğlu on 26.10.23.
//

import Foundation

class Moon: Model, Planet {
    var solarDay: Float { DemoSceneConstants.day }
    var orbitalPeriod: Float { 1 / (0.07 * DemoSceneConstants.year) }
    var distance: Float { DemoSceneConstants.earthDistance * 0.15 } // 0.003 actually
    var startAngle: Float = 0
    
    init() {
        super.init(name: "moon.obj")
        transform.position = [distance, 0, 0]
        transform.scale = DemoSceneConstants.planetScale * 0.27
    }
}
