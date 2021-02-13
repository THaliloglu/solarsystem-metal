//
//  DemoView.swift
//  SolarSystem-macOS
//
//  Created by TOLGA HALILOGLU on 13.02.2021.
//

import MetalKit

class DemoView: MTKView {
    weak var inputController: InputController?
    
    // for mouse movement
    var trackingArea : NSTrackingArea?
    var useMouse = false {
        didSet {
            inputController?.useMouse = useMouse
        }
    }
    
    override func updateTrackingAreas() {
        guard let window = NSApplication.shared.mainWindow else { return }
        window.acceptsMouseMovedEvents = useMouse
        if useMouse {
            CGDisplayHideCursor(CGMainDisplayID())
        } else {
            CGDisplayShowCursor(CGMainDisplayID())
        }
        if let trackingArea = trackingArea {
            removeTrackingArea(trackingArea)
        }
        guard useMouse else { return }
        let options: NSTrackingArea.Options = [.activeAlways, .inVisibleRect,  .mouseMoved]
        trackingArea = NSTrackingArea(rect: self.bounds, options: options,
                                      owner: self, userInfo: nil)
        addTrackingArea(trackingArea!)
    }
    
}

extension DemoView {
    override var acceptsFirstResponder: Bool {
        return true
    }
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
        return true
    }
    
    override func keyDown(with event: NSEvent) {
        guard let key = KeyboardControl(rawValue: event.keyCode) else {
            return
        }
        let state: InputState = event.isARepeat ? .continued : .began
        inputController?.processEvent(key: key, state: state)
    }
    
    override func keyUp(with event: NSEvent) {
        guard let key = KeyboardControl(rawValue: event.keyCode) else {
            return
        }
        inputController?.processEvent(key: key, state: .ended)
    }
    
    override func mouseMoved(with event: NSEvent) {
        inputController?.processEvent(mouse: .mouseMoved, state: .began, event: event)
        // reset mouse position to center of view
        guard useMouse else { return }
        let screenFrame = NSScreen.main?.frame ?? .zero
        var rect = frame
        frame = convert(rect, to: nil)
        rect = window?.convertToScreen(rect) ?? rect
        CGWarpMouseCursorPosition(NSPoint(x: (rect.origin.x + bounds.midX),
                                          y: (screenFrame.height - rect.origin.y - bounds.midY) ))
    }
    
    
    override func mouseDown(with event: NSEvent) {
        inputController?.processEvent(mouse: .leftDown, state: .began, event: event)
    }
    
    override func mouseUp(with event: NSEvent) {
        inputController?.processEvent(mouse: .leftUp, state: .ended, event: event)
    }
    
    override func mouseDragged(with event: NSEvent) {
        inputController?.processEvent(mouse: .leftDrag, state: .continued, event: event)
    }
    
    override func rightMouseDown(with event: NSEvent) {
        inputController?.processEvent(mouse: .rightDown, state: .began, event: event)
    }
    
    override func rightMouseDragged(with event: NSEvent) {
        inputController?.processEvent(mouse: .rightDrag, state: .continued, event: event)
    }
    
    override func rightMouseUp(with event: NSEvent) {
        inputController?.processEvent(mouse: .rightUp, state: .ended, event: event)
    }
    
    //  override func scrollWheel(with event: NSEvent) {
    //    inputController?.processEvent(mouse: .scroll, state: .continued, event: event)
    //  }
}
