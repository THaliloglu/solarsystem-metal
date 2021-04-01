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
    @IBOutlet weak var arrowLeft: UIImageView!
    @IBOutlet weak var arrowDown: UIImageView!
    @IBOutlet weak var arrowRight: UIImageView!
    @IBOutlet weak var arrowUp: UIImageView!
    var isTouched = false
}

extension DemoView {
    override func didMoveToWindow() {
        super.didMoveToWindow()
    }
    
    func isTouch(_ touch: UITouch?, inView view: UIView?) -> Bool {
        var retval = false
        if let view = view,
           let location = touch?.location(in: view) {
            if location.x >= 0 && location.y >= 0 &&
                location.x < view.bounds.width &&
                location.y < view.bounds.height {
                retval = true
            }
        }
        return retval
    }
    
    func processButtonEvents(forTouches touches: Set<UITouch>, withTouchState state: InputState) {
        switch state {
        case .began:
            isTouched = true
        case .ended, .cancelled:
            isTouched = false
        default:
            break
        }
        
        if isTouch(touches.first, inView: acceleratorView) {
            inputController?.processEvent(view: .accelerator, state: state)
        } else if isTouch(touches.first, inView: arrowLeft) {
            inputController?.processEvent(view: .left, state: state)
        } else if isTouch(touches.first, inView: arrowRight) {
            inputController?.processEvent(view: .right, state: state)
        } else if isTouch(touches.first, inView: arrowUp) {
            inputController?.processEvent(view: .up, state: state)
        } else if isTouch(touches.first, inView: arrowDown) {
            inputController?.processEvent(view: .down, state: state)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        processButtonEvents(forTouches: touches, withTouchState: .began)
        
        super.touchesBegan(touches, with: event)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        if isTouched {
            processButtonEvents(forTouches: touches, withTouchState: .moved)
        }
        super.touchesMoved(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        if isTouched {
            processButtonEvents(forTouches: touches, withTouchState: .ended)
        }
        super.touchesEnded(touches, with: event)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>,
                                   with event: UIEvent?) {
        isTouched = false
        super.touchesCancelled(touches, with: event)
    }
}
