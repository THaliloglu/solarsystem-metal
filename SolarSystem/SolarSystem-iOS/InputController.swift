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
    
    
    var rotationSpeed: Float = 4.0
    var translationSpeed: Float = 0.05 {
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
}


extension InputController {
    func processEvent(touches: Set<UITouch>, state: InputState, event: UIEvent?) {
        switch state {
        case .began, .moved:
            forward = true
        case .ended:
            forward = false
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
        player.rotation.y += currentPitch * deltaTime * rotationSpeed
        player.position.x += currentSpeed * sin(player.rotation.y)
        player.position.z += currentSpeed * cos(player.rotation.y)
    }
}

enum InputState {
    case began, moved, ended, cancelled, continued
}
