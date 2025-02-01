//
//  MetalView.swift
//  SolarSystem-multiplatform
//
//  Created by TOLGA HALILOGLU on 14.02.2023.
//

import SwiftUI
import MetalKit

#if os(iOS)
typealias ViewRepresentable = UIViewRepresentable
#elseif os(macOS)
typealias ViewRepresentable = NSViewRepresentable
#endif


struct MetalView: ViewRepresentable {

    #if os(iOS)
    public func makeUIView(context: Context) -> MTKView {
        makeView(context: context)
    }

    public func updateUIView(_ uiView: MTKView, context: Context) {}
    #endif

    #if os(macOS)
    public func makeNSView(context: Context) -> MTKView {
        makeView(context: context)
    }

    public func updateNSView(_ view: MTKView, context: Context) {}
    #endif
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
}

extension MetalView {

    func makeView(context: Context) -> MTKView {
        let view = DemoView()
        
        let renderer = Renderer(metalView: view)
        let scene = DemoScene(sceneSize: view.bounds.size)
        renderer.scene = scene
        
        context.coordinator.renderer = renderer
        
        return view
    }
}
