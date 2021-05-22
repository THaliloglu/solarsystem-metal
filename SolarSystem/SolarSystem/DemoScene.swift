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
    
    var rocketCamEnabled = false
    let orthoCamera = OrthographicCamera()
    
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
    
    
    let rocket = Model(name: "rocket.obj")
    let rocketStartPosition: float3 = [0, 0, -10]
    
    var asteroidBeltMinDistance:Float {
        earthDistance * 2.0
    }
    var asteroidBeltMaxDistance:Float {
        earthDistance * 2.75
    }
    var instancingEnabled = true
    let asteroidBeltInstanceCount = 1000
    
    var rocks:Nature?
    
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
        earth.position = [earthDistance, 0, 0]
        earth.scale = [planetScale, planetScale, planetScale]
        add(node: earth)
        spheres.append(earth)
        
        // Sun
        sun.position = [0, 0, 0]
        sun.scale = [earth.scale.x * 3, earth.scale.y * 3, earth.scale.z * 3]
        add(node: sun)
        spheres.append(sun)
        
        // Planets
        mercury.position = [mercuryDistance, 0, 0]
        mercury.scale = [earth.scale.x * 0.3, earth.scale.y * 0.3, earth.scale.z * 0.3]
        add(node: mercury)
        spheres.append(mercury)
        
        venus.position = [venusDistance, 0, 0]
        venus.scale = [earth.scale.x * 0.95, earth.scale.y * 0.95, earth.scale.z * 0.95]
        add(node: venus)
        spheres.append(venus)
        
        moon.position = [moonDistance, 0, 0]
        moon.scale = [earth.scale.x * 0.27, earth.scale.y * 0.27, earth.scale.z * 0.27]
        add(node: moon, parent: earth)
        spheres.append(moon)
        
        mars.position = [marsDistance, 0, 0]
        mars.scale = [earth.scale.x * 0.5, earth.scale.y * 0.5, earth.scale.z * 0.5]
        add(node: mars)
        spheres.append(mars)
        
        // Rocket Object
        rocket.position = rocketStartPosition
        rocket.scale = [0.05, 0.05, 0.05]
        add(node: rocket)
        
        // Camera
        let archballCamera = ArcballCamera()
        archballCamera.distance = 20
        archballCamera.target = [0, 0, -2]
        archballCamera.rotation.x = Float(-25).degreesToRadians
        archballCamera.position = [0, 1.2, -4]
        cameras.append(archballCamera)
        currentCameraIndex = 1
        
        inputController.player = rocket
        inputController.keyboardDelegate = self
        
        orthoCamera.position = [0, 15, 0]
        orthoCamera.rotation.x = .pi / 2
        cameras.append(orthoCamera)
        
        let tpCameraForEarth = ThirdPersonCamera(focus: earth)
        cameras.append(tpCameraForEarth)
        
        let tpCameraForRocket = ThirdPersonCamera(focus: rocket)
        tpCameraForRocket.focusHeight = 0.25
        tpCameraForRocket.focusDistance = 2
        cameras.append(tpCameraForRocket)
        
        #if os(iOS)
        currentCameraIndex = 4
        #endif
        
        physicsController.dynamicBody = rocket
        for sphere in spheres {
            physicsController.addStaticBody(node: sphere)
        }
        
        if instancingEnabled {
            let textureNames = ["rock1-color", "rock2-color", "rock3-color"]
            let morphTargetNames = ["rock1", "rock2", "rock3"]
            rocks = Nature(name: "Rocks", instanceCount: asteroidBeltInstanceCount,
                               textureNames: textureNames,
                               morphTargetNames: morphTargetNames)
            add(node: rocks!)
            for i in 0..<asteroidBeltInstanceCount {
                
                var transform = Transform()
                let t:Float = 2 * .pi * .random(in: 0..<100)
                let r:Float = .random(in: asteroidBeltMinDistance..<asteroidBeltMaxDistance)
                transform.position.x = r * cos(t)
                transform.position.z = r * sin(t)
                transform.scale = [earth.scale.x * 0.1, earth.scale.y * 0.1, earth.scale.z * 0.1]
                
                let textureID = Int.random(in: 0..<textureNames.count)
                let morphTargetID = Int.random(in: 0..<morphTargetNames.count)
                rocks!.updateBuffer(instance: i, transform: transform, textureID: textureID, morphTargetID: morphTargetID)
            }
        } else {
            for _ in 0..<asteroidBeltInstanceCount {
                let rock = Model(name: "rock1.obj")
                add(node: rock)
                
                let t:Float = 2 * .pi * .random(in: 0..<100)
                let r:Float = .random(in: asteroidBeltMinDistance..<asteroidBeltMaxDistance)
                rock.position.x = r * cos(t)
                rock.position.z = r * sin(t)
                rock.scale = [earth.scale.x * 0.1, earth.scale.y * 0.1, earth.scale.z * 0.1]

                let rotationY: Float = .random(in: -.pi..<Float.pi)
                rock.rotation = [0, rotationY, 0]
            }
        }
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
        
        // Commented out for performance concerns, needs to figuring out a way using shaders
//        for i in 0..<asteroidBeltInstanceCount {
//            rocks?.updateBufferPositions(instance: i, currentTime: earth.currentTime, orbitalPeriod: earthOrbitalPeriod)
//        }
    }
    
    override func updatePlayer(deltaTime: Float) {
        guard let node = inputController.player else { return }
        
        let holdPosition = node.position
        let holdRotation = node.rotation
        inputController.updatePlayer(deltaTime: deltaTime)
        
        if physicsController.checkCollisions() {
            //MARK: You can send the rocket to start position
            //check "rocketStartPosition"
            node.position = holdPosition
            node.rotation = holdRotation
        }
    }
    
    override func sceneSizeWillChange(to size: CGSize) {
        super.sceneSizeWillChange(to: size)
        
        let cameraSize: Float = 10
        let ratio = Float(sceneSize.width / sceneSize.height)
        let rect = Rectangle(left: -cameraSize * ratio,
                             right: cameraSize * ratio,
                             top: cameraSize,
                             bottom: -cameraSize)
        orthoCamera.rect = rect
    }
}

#if os(macOS)
extension DemoScene: KeyboardDelegate {
    func keyPressed(key: KeyboardControl, state: InputState) -> Bool {
        switch key {
        case .c where state == .ended:
            if rocketCamEnabled {
                // TODO: Add When Rocket finished
            } else {
                // TODO: Revert cam
            }
            rocketCamEnabled = !rocketCamEnabled
            return false
        case .key1:
            currentCameraIndex = 1
        case .key2:
            currentCameraIndex = 2
        case .key3:
            currentCameraIndex = 3
        case .key4:
            currentCameraIndex = 4
        case .key5 where state == .ended:
            Renderer.antialiasingEnabled = !Renderer.antialiasingEnabled
        case .key0 where state == .ended:
            debugRenderBoundingBox = !debugRenderBoundingBox
        default:
            break
        }
        return true
    }
}
#endif
