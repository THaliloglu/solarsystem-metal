//
//  MainViewControllerExtension.swift
//  SolarSystem-macOS
//
//  Created by TOLGA HALILOGLU on 28.12.2020.
//

import Cocoa

extension MainViewController {
    func addGestureRecognizers(to view: NSView) {
        let pan = NSPanGestureRecognizer(target: self, action: #selector(handlePan(gesture:)))
        view.addGestureRecognizer(pan)
    }
    
    @objc func handlePan(gesture: NSPanGestureRecognizer) {
        let translation = gesture.translation(in: gesture.view)
        let delta = float2(Float(translation.x),Float(translation.y))
        
        renderer?.scene?.camera.rotate(delta: delta)
        gesture.setTranslation(.zero, in: gesture.view)
    }
    
    override func scrollWheel(with event: NSEvent) {
        renderer?.scene?.camera.zoom(delta: Float(event.deltaY))
    }
}
