//
//  Rocket.swift
//  SolarSystem
//
//  Created by Tolga Haliloğlu on 26.10.23.
//

import Foundation

class Rocket: Model {
    init() {
        super.init(name: "rocket.obj")
        transform.position = [0, 0, -10]
        transform.scale = 0.05
    }
}

extension Rocket: Movement {}
