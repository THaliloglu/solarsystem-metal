//
//  Coordinator.swift
//  SolarSystem-multiplatform
//
//  Created by TOLGA HALILOGLU on 14.02.2023.
//

import Foundation

class Coordinator: NSObject {
    var parent: MetalView
    var renderer: Renderer?
    
    init(parent: MetalView, renderer: Renderer? = nil) {
        self.parent = parent
        self.renderer = renderer
    }
}
