//
//  DemoView.swift
//  SolarSystem-iOS
//
//  Created by TOLGA HALILOGLU on 13.02.2021.
//

import MetalKit

class DemoView: MTKView {
    var inputController: InputController?
    var motionController = MotionController()
    @IBOutlet weak var acceleratorView: UIView!
    var isTouched = false
}

extension DemoView {
    override func didMoveToWindow() {
        super.didMoveToWindow()
        motionController.motionClosure = {
            motion, error in
            guard let motion = motion else { return }
            let gravityAngle = atan2(motion.gravity.y, motion.gravity.x)
            let sign: Float = abs(gravityAngle) <= 1 ? -1 : 1
            let sensitivity: Float = 60
            self.inputController?.currentTurnSpeed = sign * Float(motion.attitude.pitch) * sensitivity
            self.inputController?.currentPitch = sign * Float(motion.attitude.pitch)
        }
        motionController.setupCoreMotion()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        
        // only process touch in accelerator view
        if let acceleratorView = acceleratorView,
           let location = touches.first?.location(in: acceleratorView) {
            if location.x >= 0 && location.y >= 0 &&
                location.x < acceleratorView.bounds.width &&
                location.y < acceleratorView.bounds.height {
                isTouched = true
                inputController?.processEvent(touches: touches, state: .began, event: event)
            }
        }
        super.touchesBegan(touches, with: event)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        if isTouched {
            inputController?.processEvent(touches: touches, state: .moved, event: event)
        }
        super.touchesMoved(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        if isTouched {
            inputController?.processEvent(touches: touches, state: .ended, event: event)
        }
        isTouched = false
        super.touchesEnded(touches, with: event)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>,
                                   with event: UIEvent?) {
        isTouched = false
        super.touchesCancelled(touches, with: event)
    }
}
