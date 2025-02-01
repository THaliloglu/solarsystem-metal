//
//  Sun.swift
//  SolarSystem
//
//  Created by Tolga Haliloğlu on 26.10.23.
//

import Foundation

class Sun: Model {
    var solarDay: Float { 1 / (1.04 * DemoSceneConstants.day) }
    
    init() {
        super.init(name: "sun.obj")
        transform.position = [0, 0, 0]
        transform.scale = DemoSceneConstants.planetScale * 3 // Should be 87.4
    }
}
