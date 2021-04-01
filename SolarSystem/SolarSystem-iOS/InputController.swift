//
//  InputController.swift
//  SolarSystem-iOS
//
//  Created by TOLGA HALILOGLU on 13.02.2021.
//

import MetalKit

class InputController {
    var player: Node?
    var currentSpeed: Float = 0
    
    var rotationSpeed: Float = 1.0
    var translationSpeed: Float = 1.0 {
        didSet {
            if translationSpeed > maxSpeed {
                translationSpeed = maxSpeed
            }
        }
    }
    let maxSpeed: Float = 0.1
    var currentTurnSpeed: Float = 0
    var currentPitch: Float = 0
    var forward = false
    
    // conforming to macOS
    var keyboardDelegate: Any?
    
    var directionViewsDown: Set<ViewControl> = []
}


extension InputController {
    
    func processEvent(view inView: ViewControl, state: InputState) {
        let view = inView
        switch state {
        case .began, .moved:
            if view == .accelerator {
                forward = true
            }
            directionViewsDown.insert(view)
        case .ended:
            if view == .accelerator {
                forward = false
            }
            directionViewsDown.remove(view)
        default:
            break
        }
    }
    
    public func updatePlayer(deltaTime: Float) {
        guard let player = player else { return }
        let translationSpeed = deltaTime * self.translationSpeed
        currentSpeed = forward ? currentSpeed + translationSpeed :
            currentSpeed - translationSpeed * 2
        if currentSpeed < 0 {
            currentSpeed = 0
        } else if currentSpeed > maxSpeed {
            currentSpeed = maxSpeed
        }
        let rotationSpeed = deltaTime * self.rotationSpeed
        
        var direction: float3 = [0, 0, 0]
        for view in directionViewsDown {
            switch view {
            case .accelerator:
                direction.z += 1
            //MARK: - support 3 dimension
//            case .w:
//                player.rotation.x += rotationSpeed
            case .left:
                player.rotation.y -= rotationSpeed
            //MARK: - support 3 dimension
//            case .s:
//                player.rotation.x -= rotationSpeed
            case .right:
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
            player.position += (direction.z * player.forwardVector + direction.x * player.rightVector) * currentSpeed
        }
        
    }
}

enum ViewControl {
    case accelerator, left, down, right, up
}

enum InputState {
    case began, moved, ended, cancelled, continued
}
