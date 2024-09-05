//
//  Earth.swift
//  SolarSystem
//
//  Created by Tolga Haliloğlu on 26.10.23.
//

import Foundation

class Earth: Model, Planet {
    var solarDay: Float { DemoSceneConstants.day }
    var orbitalPeriod: Float { 1 / DemoSceneConstants.year }
    var distance: Float { DemoSceneConstants.earthDistance }
    var startAngle: Float = 0
    
    init() {
        super.init(name: "earth.obj")
        transform.position = [distance, 0, 0]
        transform.scale = DemoSceneConstants.planetScale
    }
}

extension Earth: Movement {}
