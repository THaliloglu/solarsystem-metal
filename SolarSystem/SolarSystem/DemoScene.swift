//
//  DemoScene.swift
//  SolarSystem
//
//  Created by TOLGA HALILOGLU on 13.02.2021.
//

import Foundation
import CoreGraphics

class DemoScene: Scene {
    enum RotationDirection: Float {
        case clockwise = 1
        case counterclockwise = -1
    }
    
    // Constants
    let planetScale:Float = 0.8
    let day:Float = 2
    var year:Float {
        (365 * day)/365
    }
    
    // Sun
    let sun = Model(name: "sun.obj")
    var sunSolarDay: Float {
        1 / (1.04 * day)
    }
    
    // Mercury
    let mercury = Model(name: "mercury.obj")
    var mercurySolarDay:Float {
        1 / (58 * day)
    }
    var mercuryOrbitalPeriod:Float {
        1 / (0.2 * year)
    }
    var mercuryDistance:Float {
        earthDistance * 0.4
    }
    let mercuryStartAngle:Float = 10
    
    // Venus
    let venus = Model(name: "venus.obj")
    var venusSolarDay:Float {
        1 / (243 * day)
    }
    var venusOrbitalPeriod:Float {
        1 / (0.6 * year)
    }
    var venusDistance:Float {
        earthDistance * 0.7
    }
    let venusStartAngle:Float = 20
    
    // Earth
    let earth = Model(name: "earth.obj")
    var earthSolarDay:Float {
        day
    }
    var earthOrbitalPeriod:Float {
        1 / year
    }
    let earthDistance:Float = 10
    let earthStartAngle:Float = 0
    
    // Moon
    let moon = Model(name: "moon.obj")
    var moonSolarDay:Float {
        earthSolarDay
    }
    var moonOrbitalPeriod:Float {
        1 / (0.07 * year)
    }
    var moonDistance:Float {
        earthDistance * 0.15 // 0.003 actually
    }
    
    // Mars
    let mars = Model(name: "mars.obj")
    var marsSolarDay:Float {
        1 / (1.04 * day)
    }
    var marsOrbitalPeriod:Float {
        1 / (1.9 * year)
    }
    var marsDistance:Float {
        earthDistance * 1.5
    }
    let marsStartAngle: Float = 30
    
    override func setupScene() {
        // earth oriented
        earth.position = [earthDistance, 0, 0]
        earth.scale = [planetScale, planetScale, planetScale]
        add(node: earth)
        
        // Sun
        sun.position = [0, 0, 0]
        sun.scale = [earth.scale.x * 3, earth.scale.y * 3, earth.scale.z * 3]
        add(node: sun)
        
        // Planets
        mercury.position = [mercuryDistance, 0, 0]
        mercury.scale = [earth.scale.x * 0.3, earth.scale.y * 0.3, earth.scale.z * 0.3]
        add(node: mercury)
        
        venus.position = [venusDistance, 0, 0]
        venus.scale = [earth.scale.x * 0.95, earth.scale.y * 0.95, earth.scale.z * 0.95]
        add(node: venus)
        
        moon.position = [moonDistance, 0, 0]
        moon.scale = [earth.scale.x * 0.27, earth.scale.y * 0.27, earth.scale.z * 0.27]
        add(node: moon, parent: earth)
        
        mars.position = [marsDistance, 0, 0]
        mars.scale = [earth.scale.x * 0.5, earth.scale.y * 0.5, earth.scale.z * 0.5]
        add(node: mars)
        
        // Camera
        camera.distance = 15
        camera.target = [0, 0, -2]
        camera.rotation.x = Float(-25).degreesToRadians
        camera.position = [0, 1.2, -4]
    }
    
    override func updateScene(deltaTime: Float) {
        sun.rotation = [0,(earth.currentTime * sunSolarDay) * RotationDirection.counterclockwise.rawValue, 0]

        mercury.rotation = [0, (mercury.currentTime * mercurySolarDay) * RotationDirection.counterclockwise.rawValue , 0]
        mercury.position = [ sin((mercuryStartAngle + mercury.currentTime) * mercuryOrbitalPeriod) * mercuryDistance,
                            mercury.position.y,
                            -cos((mercuryStartAngle + mercury.currentTime) * mercuryOrbitalPeriod) * mercuryDistance]

        venus.rotation = [0, (venus.currentTime * venusSolarDay) * RotationDirection.clockwise.rawValue, 0]
        venus.position = [ sin((venusStartAngle + venus.currentTime) * venusOrbitalPeriod) * venusDistance,
                          venus.position.y,
                          -cos((venusStartAngle + venus.currentTime) * venusOrbitalPeriod) * venusDistance]

        earth.rotation = [0, (earth.currentTime * earthSolarDay) * RotationDirection.counterclockwise.rawValue, 0]
        earth.position = [ sin((earthStartAngle + earth.currentTime) * earthOrbitalPeriod) * earthDistance,
                          earth.position.y,
                          -cos((earthStartAngle + earth.currentTime) * earthOrbitalPeriod) * earthDistance]

        moon.rotation = [0, (moon.currentTime * moonSolarDay) * RotationDirection.counterclockwise.rawValue, 0]
        moon.position = [sin(moon.currentTime * moonOrbitalPeriod) * moonDistance,
                         earth.position.y,
                         -cos(moon.currentTime * moonOrbitalPeriod) * moonDistance]

        mars.rotation = [0, (mars.currentTime * marsSolarDay) * RotationDirection.counterclockwise.rawValue, 0]
        mars.position = [sin((marsStartAngle + mars.currentTime) * marsOrbitalPeriod) * marsDistance,
                         mars.position.y,
                         -cos((marsStartAngle + mars.currentTime) * marsOrbitalPeriod) * marsDistance]
    }
}
