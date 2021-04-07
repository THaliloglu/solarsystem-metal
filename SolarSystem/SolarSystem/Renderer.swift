//
//  Renderer.swift
//  SolarSystem
//
//  Created by Tolga Haliloğlu on 20.12.2020.
//

import MetalKit
class Renderer: NSObject {
    
    static var device: MTLDevice!
    static var commandQueue: MTLCommandQueue!
    static var library: MTLLibrary!
    static var colorPixelFormat: MTLPixelFormat!
    
    var scene: Scene?
    
    let depthStencilState: MTLDepthStencilState
    static func buildDepthStencilState() -> MTLDepthStencilState? {
        let descriptor = MTLDepthStencilDescriptor()
        descriptor.depthCompareFunction = .less
        descriptor.isDepthWriteEnabled = true
        return Renderer.device.makeDepthStencilState(descriptor: descriptor)
    }
    
    static var antialiasingSampleCount = 4
    static var antialiasingEnabled = true
    
    // Debug drawing of lights
    lazy var lightPipelineState: MTLRenderPipelineState = {
        return buildLightPipelineState()
    }()
    
    static var fps: Int!
    
    init(metalView: MTKView) {
        guard let device = MTLCreateSystemDefaultDevice(),
              let commandQueue = device.makeCommandQueue() else {
            fatalError("GPU not available")
        }
        
        Renderer.device = device
        Renderer.commandQueue = commandQueue
        Renderer.library = device.makeDefaultLibrary()
        Renderer.colorPixelFormat = metalView.colorPixelFormat
        Renderer.fps = metalView.preferredFramesPerSecond // default 60 fps (11.6ms)
        metalView.device = device
        metalView.depthStencilPixelFormat = .depth32Float
        depthStencilState = Renderer.buildDepthStencilState()!
        
        super.init()
        
        metalView.clearColor = MTLClearColor(red: 1.0, green: 1.0,
                                             blue: 0.8, alpha: 1.0)
        metalView.delegate = self
        mtkView(metalView, drawableSizeWillChange: metalView.bounds.size)
    }
}

extension Renderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        scene?.sceneSizeWillChange(to: size)
    }
    
    func draw(in view: MTKView) {
        view.sampleCount = Renderer.antialiasingEnabled ? Renderer.antialiasingSampleCount : 1
        guard
            let scene = scene,
            let descriptor = view.currentRenderPassDescriptor,
            let commandBuffer = Renderer.commandQueue.makeCommandBuffer(),
            let renderEncoder = commandBuffer.makeRenderCommandEncoder( descriptor: descriptor) else {
            return
        }
                
        let deltaTime = 1 / Float(Renderer.fps)
        scene.update(deltaTime: deltaTime)
        
        renderEncoder.setDepthStencilState(depthStencilState)
        
        var lights = scene.lighting.lights
        renderEncoder.setFragmentBytes(&lights, length: MemoryLayout<Light>.stride * lights.count, index: Int(BufferIndexLights.rawValue))
        
        // render all the models in the array
        for renderable in scene.renderables {
            renderEncoder.pushDebugGroup(renderable.name)
            renderable.render(renderEncoder: renderEncoder,
                              uniforms: scene.uniforms,
                              fragmentUniforms: scene.fragmentUniforms)
            renderEncoder.popDebugGroup()
        }
        
//        debugLights(renderEncoder: renderEncoder, lightType: Sunlight)
//        debugLights(renderEncoder: renderEncoder, lightType: Pointlight)
//        debugLights(renderEncoder: renderEncoder, lightType: Spotlight)
        
        renderEncoder.endEncoding()
        guard let drawable = view.currentDrawable else {
            return
        }
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
