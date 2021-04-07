//
//  InputController.swift
//  SolarSystem-macOS
//
//  Created by TOLGA HALILOGLU on 13.02.2021.
//

import Cocoa

protocol KeyboardDelegate {
    func keyPressed(key: KeyboardControl, state: InputState) -> Bool
}

protocol MouseDelegate {
    func mouseEvent(mouse: MouseControl, state: InputState,
                    delta: float3, location: float2)
}

class InputController {
    var player: Node?
    var translationSpeed: Float = 1.0
    var rotationSpeed: Float = 1.0
    
//    var upVector: float3 = [0, 1, 0]
//    var forwardVector: float3 = [0, 0, 1]
//    var rightVector: float3 = [1, 0, 0]
//    var currentThrust: Float = 0
//    var maximumThrust: Float = 1
    
    var keyboardDelegate: KeyboardDelegate?
    var directionKeysDown: Set<KeyboardControl> = []
    
    var mouseDelegate: MouseDelegate?
    var useMouse = false
    
    func processEvent(key inKey: KeyboardControl, state: InputState) {
        let key = inKey
        if !(keyboardDelegate?.keyPressed(key: key, state: state) ?? true) {
            return
        }
        if state == .began {
            directionKeysDown.insert(key)
        }
        if state == .ended {
            directionKeysDown.remove(key)
        }
    }
    
    func processEvent(mouse: MouseControl, state: InputState, event: NSEvent) {
        let delta: float3 = [Float(event.deltaX), Float(event.deltaY), Float(event.deltaZ)]
        let locationInWindow: float2 = [Float(event.locationInWindow.x), Float(event.locationInWindow.y)]
        mouseDelegate?.mouseEvent(mouse: mouse, state: state, delta: delta, location: locationInWindow)
    }
    
    public func updatePlayer(deltaTime: Float) {
        guard let player = player else { return }
        
        let translationSpeed = deltaTime * self.translationSpeed
        let rotationSpeed = deltaTime * self.rotationSpeed
        var direction: float3 = [0, 0, 0]
        for key in directionKeysDown {
            switch key {
            case .space:
                direction.z += 1
            //MARK: - support 3 dimension
//            case .w:
//                player.rotation.x += rotationSpeed
            case .a:
                player.rotation.y -= rotationSpeed
            //MARK: - support 3 dimension
//            case .s:
//                player.rotation.x -= rotationSpeed
            case .d:
                player.rotation.y += rotationSpeed
            //FIXME: uptate rocket object origin points
//            case .q:
//                player.rotation.z += rotationSpeed
//            case .e:
//                player.rotation.z -= rotationSpeed
            default:
                break
            }
        }
        
        if direction != [0, 0, 0] {
            direction = normalize(direction)
            player.position += (direction.z * player.forwardVector + direction.x * player.rightVector) * translationSpeed
        }
        
        
        // New development ======
//        let translationSpeed = deltaTime * self.currentThrust
//        let rotationSpeed = deltaTime * self.rotationSpeed
//        for key in directionKeysDown {
//            switch key {
//            case .space:
//                currentThrust = maximumThrust
//            case .w, .s:
//                // pitch - rotation on x axis
//                let speed = key == .w ? rotationSpeed : -rotationSpeed
//                let pitch = simd_quatf(angle: speed, axis: rightVector)
//                forwardVector = pitch.act(forwardVector)
//                forwardVector = normalize(forwardVector)
//                upVector = cross(forwardVector, rightVector)
//            case .q, .e:
//                // yaw - rotation on y axis
//                let speed = key == .e ? rotationSpeed : -rotationSpeed
//                let yaw = simd_quatf(angle: speed, axis: upVector)
//                rightVector = yaw.act(rightVector)
//                rightVector = normalize(rightVector)
//                forwardVector = cross(rightVector, upVector)
//            case .a, .d:
//                // roll - rotation on z axis
//                let speed = key == .a ? rotationSpeed : -rotationSpeed
//                let roll = simd_quatf(angle: speed,
//                                      axis: forwardVector)
//                upVector = roll.act(upVector)
//                upVector = normalize(upVector)
//                rightVector = cross(upVector, forwardVector)
//            default:
//                break
//            }
//            print(length(forwardVector), length(upVector), length(rightVector))
//            player.position += translationSpeed * forwardVector
//
//            let right: float4 = float4(rightVector.x, rightVector.y, rightVector.z, 0)
//            let up: float4 = float4(upVector.x, upVector.y, upVector.z, 0)
//            let forward: float4 = float4(forwardVector.x, forwardVector.y, forwardVector.z, 0)
//            let rotationMatrix = float4x4(right, up, forward, [0, 0, 0, 1])
//            player.quaternion = simd_quatf(rotationMatrix)
//        }
        // New development ======
        
    }
}

enum InputState {
    case began, moved, ended, cancelled, continued
}

enum KeyboardControl: UInt16 {
    case a =      0
    case d =      2
    case w =      13
    case s =      1
    case down =   125
    case up =     126
    case right =  124
    case left =   123
    case q =      12
    case e =      14
    case key1 =   18
    case key2 =   19
    case key3 =   20
    case key4 =   21
    case key5 =   23
    case key0 =   29
    case space =  49
    case c = 8
}

enum MouseControl {
    case leftDown, leftUp, leftDrag, rightDown, rightUp, rightDrag, scroll, mouseMoved
}
