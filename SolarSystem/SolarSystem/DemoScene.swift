//
//  DemoScene.swift
//  SolarSystem
//
//  Created by TOLGA HALILOGLU on 13.02.2021.
//

import Foundation
import CoreGraphics
import Combine

enum DemoSceneConstants {
    static var planetScale: Float = 0.8
    static var day: Float = 2
    static var year: Float { (365 * day)/365 }
    static var earthDistance:Float = 10
}

class DemoScene: MetalScene {
    enum RotationDirection: Float {
        case clockwise = 1
        case counterclockwise = -1
    }
    
    var rocketCamEnabled = false
    var orthoCamera = OrthographicCamera()
    
    // Sun
    let sun = Sun()
    
    // Mercury
    let mercury = Mercury()
    
    // Venus
    let venus = Venus()
    
    // Earth
    let earth = Earth()
    
    // Moon
    let moon = Moon()
    
    // Mars
    let mars = Mars()
    
    // Rocket
    let rocket = Rocket()
    
    var asteroidBeltMinDistance:Float {
        DemoSceneConstants.earthDistance * 2.2
    }
    var asteroidBeltMaxDistance:Float {
        DemoSceneConstants.earthDistance * 3
    }
    let asteroidBeltInstanceCount = 10000
    
    var rocks:Nature?
    
    private var cancellables = Set<AnyCancellable>()
    
    override func setupScene() {
        // Option Menu Values;
        // - time slider
        // - collisions cube on/off
        // - antialiasing value change
        // - skybox procedural or cube texture
        // - asteroid belt instance count
        
//        skybox = Skybox(textureName: nil) // procedural
        skybox = Skybox(textureName: "skybox-stars")
        
        var spheres: [Node] = []
        
        // earth oriented
        add(node: earth)
        spheres.append(earth)
        
        // Sun
        add(node: sun)
        spheres.append(sun)
        
        // Planets
        add(node: mercury)
        spheres.append(mercury)
        
        add(node: venus)
        spheres.append(venus)
        
        add(node: moon, parent: earth)
        spheres.append(moon)
        
        add(node: mars)
        spheres.append(mars)
        
        // Rocket Object
        add(node: rocket)
        
        // Camera
        var archballCamera = ArcballCamera()
        archballCamera.distance = 30
        archballCamera.target = [0, 0, -2]
        archballCamera.rotation.x = Float(-25).degreesToRadians
        archballCamera.position = [0, 1.2, -4]
        cameras.append(archballCamera)
        currentCameraIndex = 1
        
//        inputController.player = rocket
//        inputController.keyboardDelegate = self
        
        orthoCamera.position = [0, 15, 0]
        orthoCamera.rotation.x = .pi / 2
        cameras.append(orthoCamera)
        
        let tpCameraForEarth = TPCamera(focus: earth)
        cameras.append(tpCameraForEarth)
        
        let tpCameraForRocket = TPCamera(focus: rocket)
        tpCameraForRocket.focusHeight = 0.25
        tpCameraForRocket.focusDistance = 2
        cameras.append(tpCameraForRocket)
        
        #if os(iOS)
        currentCameraIndex = 4
        #endif
        
        let physicsController = PhysicsController.shared
        physicsController.dynamicBody = rocket
        for sphere in spheres {
            physicsController.addStaticBody(node: sphere)
        }
        
        // Asteroid Belt
        let textureNames = ["rock1-color", "rock2-color", "rock3-color"]
        let morphTargetNames = ["rock1", "rock2", "rock3"]
        rocks = Nature(name: "Rocks", instanceCount: asteroidBeltInstanceCount,
                           textureNames: textureNames,
                           morphTargetNames: morphTargetNames)
        add(node: rocks!)
        for i in 0..<asteroidBeltInstanceCount {
            let transform = Transform()
            let t:Float = 2 * .pi * .random(in: 0..<100)
            let r:Float = .random(in: asteroidBeltMinDistance..<asteroidBeltMaxDistance)
            transform.position.x = r * sin(t)
            transform.position.z = -(r * cos(t))
            transform.scale = DemoSceneConstants.planetScale * 0.05
            
            let textureID = Int.random(in: 0..<textureNames.count)
            let morphTargetID = Int.random(in: 0..<morphTargetNames.count)
            rocks!.updateBuffer(instance: i, transform: transform, textureID: textureID, morphTargetID: morphTargetID)
        }
        
        let inputController = InputController.shared

        inputController.$keysPressed
            .sink { [weak self] keys in
//                print("Keys pressed: \(keys)")
                
                guard let self = self else { return }
                
                switch keys.first {
                case .one:
                    currentCameraIndex = 1
                case .two:
                    currentCameraIndex = 2
                case .three:
                    currentCameraIndex = 3
                case .four:
                    currentCameraIndex = 4
                case .five:
                    Renderer.antialiasingEnabled = !Renderer.antialiasingEnabled
                case .zero:
                    debugRenderBoundingBox = !debugRenderBoundingBox
                default: break
                }
            }
            .store(in: &cancellables)
    }
    
    override func updateScene(deltaTime: Float) {
        cameras[currentCameraIndex].update(deltaTime: deltaTime)
        
        sun.transform.rotation = [0,(earth.currentTime * sun.solarDay) * RotationDirection.counterclockwise.rawValue, 0]
        
        mercury.transform.rotation = [0, (mercury.currentTime * mercury.solarDay) * RotationDirection.counterclockwise.rawValue , 0]
        mercury.transform.position = [ sin((mercury.startAngle + mercury.currentTime) * mercury.orbitalPeriod) * mercury.distance,
                             mercury.position.y,
                                       -cos((mercury.startAngle + mercury.currentTime) * mercury.orbitalPeriod) * mercury.distance]
        
        venus.transform.rotation = [0, (venus.currentTime * venus.solarDay) * RotationDirection.clockwise.rawValue, 0]
        venus.transform.position = [ sin((venus.startAngle + venus.currentTime) * venus.orbitalPeriod) * venus.distance,
                           venus.position.y,
                           -cos((venus.startAngle + venus.currentTime) * venus.orbitalPeriod) * venus.distance]
        
        earth.transform.rotation = [0, (earth.currentTime * earth.solarDay) * RotationDirection.counterclockwise.rawValue, 0]
        earth.transform.position = [ sin((earth.startAngle + earth.currentTime) * earth.orbitalPeriod) * earth.distance,
                           earth.position.y,
                           -cos((earth.startAngle + earth.currentTime) * earth.orbitalPeriod) * earth.distance]
        
        moon.transform.rotation = [0, (moon.currentTime * moon.solarDay) * RotationDirection.counterclockwise.rawValue, 0]
        moon.transform.position = [sin(moon.currentTime * moon.orbitalPeriod) * moon.distance,
                         earth.position.y,
                         -cos(moon.currentTime * moon.orbitalPeriod) * moon.distance]
        
        mars.transform.rotation = [0, (mars.currentTime * mars.solarDay) * RotationDirection.counterclockwise.rawValue, 0]
        mars.transform.position = [sin((mars.startAngle + mars.currentTime) * mars.orbitalPeriod) * mars.distance,
                         mars.position.y,
                         -cos((mars.startAngle + mars.currentTime) * mars.orbitalPeriod) * mars.distance]
        
        let angularVelocity = (2 * Float.pi) / 10 // Example orbital period of 10 seconds
        rocks?.updateInstances(time: earth.currentTime, angularVelocity: angularVelocity)
    }
    
    override func updatePlayer(deltaTime: Float) {
//        guard let node = inputController.player else { return }
//
//        let holdPosition = node.position
//        let holdRotation = node.rotation
//        inputController.updatePlayer(deltaTime: deltaTime)
//
//        if physicsController.checkCollisions() {
//            //MARK: You can send the rocket to start position
//            //check "rocketStartPosition"
//            node.position = holdPosition
//            node.rotation = holdRotation
//        }
    }
    
    override func sceneSizeWillChange(to size: CGSize) {
        super.sceneSizeWillChange(to: size)
        cameras[currentCameraIndex].update(size: size)
    }
}
