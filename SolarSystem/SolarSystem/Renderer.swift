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
    
    let depthStencilState: MTLDepthStencilState
    static func buildDepthStencilState() -> MTLDepthStencilState? {
        let descriptor = MTLDepthStencilDescriptor()
        descriptor.depthCompareFunction = .less
        descriptor.isDepthWriteEnabled = true
        return Renderer.device.makeDepthStencilState(descriptor: descriptor)
    }
    
    // Array of Models allows for rendering multiple models
    var models: [Model] = []
    
    // Debug drawing of lights
    lazy var lightPipelineState: MTLRenderPipelineState = {
        return buildLightPipelineState()
    }()
    
    var timer: Float = 0
    
    var fragmentUniforms = FragmentUniforms()
    var uniforms = Uniforms()
    let lighting = Lighting()
    
    // Camera holds view and projection matrices
    lazy var camera: Camera = {
        let camera = ArcballCamera()
        camera.distance = 2.5
        camera.target = [0, 0, -2]
        camera.rotation.x = Float(-25).degreesToRadians
        
        return camera
    }()
    
    init(metalView: MTKView) {
        guard let device = MTLCreateSystemDefaultDevice(),
              let commandQueue = device.makeCommandQueue() else {
            fatalError("GPU not available")
        }
        
        Renderer.device = device
        Renderer.commandQueue = commandQueue
        Renderer.library = device.makeDefaultLibrary()
        Renderer.colorPixelFormat = metalView.colorPixelFormat
        metalView.device = device
        metalView.depthStencilPixelFormat = .depth32Float
        depthStencilState = Renderer.buildDepthStencilState()!
        
        super.init()
        
        metalView.clearColor = MTLClearColor(red: 1.0, green: 1.0,
                                             blue: 0.8, alpha: 1.0)
        metalView.delegate = self
        mtkView(metalView, drawableSizeWillChange: metalView.bounds.size)
        
        // TODO: Primitive mesh has problems about normals, needs to check
//        let spherePrimitive = Model(sphere: 1)
//        spherePrimitive.position = [0, 0, 0]
//        models.append(spherePrimitive)
        
        let spherePrimitive = Model(name: "sphere.obj")
        spherePrimitive.position = [0, 0, 0]
        spherePrimitive.name = "SpherePrimitive"
        models.append(spherePrimitive)
        
        let sphere = Model(name: "sphere.obj")
        sphere.position = [0, 0, 0]
        sphere.scale = [0.25, 0.25, 0.25]
        models.append(sphere)
        
        fragmentUniforms.lightCount = lighting.count
    }
}

extension Renderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        camera.aspect = Float(view.bounds.width)/Float(view.bounds.height)
    }
    
    func draw(in view: MTKView) {
        guard
            let descriptor = view.currentRenderPassDescriptor,
            let commandBuffer = Renderer.commandQueue.makeCommandBuffer(),
            let renderEncoder = commandBuffer.makeRenderCommandEncoder( descriptor: descriptor) else {
            return
        }
        
        renderEncoder.setDepthStencilState(depthStencilState)
        
        // drawing code goes here
        uniforms.projectionMatrix = camera.projectionMatrix
        uniforms.viewMatrix = camera.viewMatrix
        fragmentUniforms.cameraPosition = camera.position
        
        var lights = lighting.lights
        renderEncoder.setFragmentBytes(&lights, length: MemoryLayout<Light>.stride * lights.count, index: Int(BufferIndexLights.rawValue))
        
        // render all the models in the array
        for model in models {
            
            renderEncoder.pushDebugGroup(model.name)
            
            if model.name != "SpherePrimitive" {
                timer += 0.005
                model.position = [sin(timer) * 2, model.position.y, -cos(timer) * 2]
                model.rotation = [0, timer * 2, 0]
            } else {
                model.rotation = [0, timer, 0]
            }
            
            model.render(renderEncoder: renderEncoder, uniforms: uniforms, fragmentUniforms: fragmentUniforms)
            
            renderEncoder.popDebugGroup()
        }
        
        //        debugLights(renderEncoder: renderEncoder, lightType: Sunlight)
        debugLights(renderEncoder: renderEncoder, lightType: Pointlight)
        debugLights(renderEncoder: renderEncoder, lightType: Spotlight)
        
        renderEncoder.endEncoding()
        guard let drawable = view.currentDrawable else {
            return
        }
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
