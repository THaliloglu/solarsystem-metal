//
//  Renderable.swift
//  SolarSystem
//
//  Created by TOLGA HALILOGLU on 30.01.2021.
//

import MetalKit

protocol Renderable {
    var name: String { get }
    func render(renderEncoder: MTLRenderCommandEncoder,
                uniforms: Uniforms,
                fragmentUniforms fragment: FragmentUniforms)
}
