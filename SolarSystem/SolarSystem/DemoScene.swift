//
//  DemoScene.swift
//  SolarSystem
//
//  Created by TOLGA HALILOGLU on 13.02.2021.
//

import Foundation
import CoreGraphics

class DemoScene: Scene {
    let earth = Model(name: "earth.obj")
    let moon = Model(name: "moon.obj")
    
    override func setupScene() {
        earth.position = [0, 0, 0]
        add(node: earth)
        
        moon.position = [0, 0, 0]
        moon.scale = [0.25, 0.25, 0.25]
        add(node: moon)
        
        camera.distance = 2.5
        camera.target = [0, 0, -2]
        camera.rotation.x = Float(-25).degreesToRadians
        camera.position = [0, 1.2, -4]
    }
    
    override func updateScene(deltaTime: Float) {
        earth.rotation = [0,earth.currentTime, 0]
        
        moon.currentTime += 0.005
        moon.position = [sin(moon.currentTime) * 2, earth.position.y, -cos(moon.currentTime) * 2]
        moon.rotation = [0, moon.currentTime * 2, 0]
    }
}
