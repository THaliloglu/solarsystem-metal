//
//  InputController.swift
//  SolarSystem
//
//  Created by Tolga Haliloğlu on 19.10.23.
//

import GameController
import Combine

class InputController: ObservableObject {
    struct Point {
        var x: Float
        var y: Float
        static let zero = Point(x: 0, y: 0)
    }
    
    var leftMouseDown = false
    var mouseDelta = Point.zero
    var mouseScroll = Point.zero
    var touchLocation: CGPoint?
    var touchDelta: CGSize? {
        didSet {
            touchDelta?.height *= -1
            if let delta = touchDelta {
                mouseDelta = Point(x: Float(delta.width), y: Float(delta.height))
            }
            leftMouseDown = touchDelta != nil
        }
    }
    
    // Make keysPressed observable using Combine
    @Published var keysPressed: Set<GCKeyCode> = []
    
    static let shared = InputController()
        
    private init() {
        let center = NotificationCenter.default
        
        // Keyboard handling
        center.addObserver(
            forName: .GCKeyboardDidConnect,
            object: nil,
            queue: nil) { notification in
                let keyboard = notification.object as? GCKeyboard
                keyboard?.keyboardInput?.keyChangedHandler
                = { _, _, keyCode, pressed in
                    if pressed {
                        self.keysPressed.insert(keyCode)
                    } else {
                        self.keysPressed.remove(keyCode)
                    }
                }
            }
        
#if os(macOS)
        NSEvent.addLocalMonitorForEvents(matching: [.keyUp, .keyDown]) { _ in nil }
#endif

        // Mouse handling
        center.addObserver(
            forName: .GCMouseDidConnect,
            object: nil,
            queue: nil) { notification in
                let mouse = notification.object as? GCMouse
                mouse?.mouseInput?.leftButton.pressedChangedHandler = { _, _, pressed in
                    self.leftMouseDown = pressed
                }
                mouse?.mouseInput?.mouseMovedHandler = { _, deltaX, deltaY in
                    self.mouseDelta = Point(x: deltaX, y: deltaY)
                }
                mouse?.mouseInput?.scroll.valueChangedHandler = { _, xValue, yValue in
                    self.mouseScroll.x = xValue
                    self.mouseScroll.y = yValue
                }
            }
    }
}
