//
//  Planet.swift
//  SolarSystem
//
//  Created by Tolga Haliloğlu on 26.10.23.
//

import Foundation

protocol Planet {
    var solarDay: Float { get }
    var orbitalPeriod: Float { get }
    var distance: Float { get }
    var startAngle: Float { get }
}
