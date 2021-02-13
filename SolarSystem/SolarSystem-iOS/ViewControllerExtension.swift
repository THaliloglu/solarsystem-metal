//
//  ViewControllerExtension.swift
//  SolarSystem-iOS
//
//  Created by TOLGA HALILOGLU on 28.12.2020.
//

import UIKit

extension ViewController {
    static var previousScale: CGFloat = 1
    
    func addGestureRecognizers(to view: UIView) {
        let pan = UIPanGestureRecognizer(target: self,
                                         action: #selector(handlePan(gesture:)))
        view.addGestureRecognizer(pan)
        
        let pinch = UIPinchGestureRecognizer(target: self,
                                             action: #selector(handlePinch(gesture:)))
        view.addGestureRecognizer(pinch)
    }
    
    @objc func handlePan(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: gesture.view)
        let delta = float2(Float(translation.x), Float(-translation.y))
        
        renderer?.scene?.camera.rotate(delta: delta)
        gesture.setTranslation(.zero, in: gesture.view)
    }
    
    @objc func handlePinch(gesture: UIPinchGestureRecognizer) {
        let sensitivity: Float = 3
        let delta = Float(gesture.scale - ViewController.previousScale) * sensitivity
        renderer?.scene?.camera.zoom(delta: delta)
        ViewController.previousScale = gesture.scale
        if gesture.state == .ended {
            ViewController.previousScale = 1
        }
    }
}
