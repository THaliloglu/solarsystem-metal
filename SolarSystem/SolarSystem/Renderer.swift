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
    
    static var fps: Int!
        
    var currentTime: Float = 0
//    var ballVelocity: Float = 0
    func update(deltaTime: Float) {
        currentTime += deltaTime
        
//        let gravity: Float = 9.8 // meter / sec2
//        let mass: Float = 0.05
//        let acceleration = gravity / mass
//        let airFriction: Float = 0.2
//        let bounciness: Float = 0.9
//        let timeStep: Float = 1 / 600
//
//        ballVelocity += (acceleration * timeStep) / airFriction
//        ball.position.y -= ballVelocity * timeStep
//        if ball.position.y <= 0.35 { // collision with ground
//            ball.position.y = 0.35
//            ballVelocity = ballVelocity * -1 * bounciness
//        }
        
        for model in models {
            if model.name != "SpherePrimitive" {
                currentTime += 0.005
                
//                var animation = Animation()
//                animation.translations = generateSphereTranslations()
//                model.position = animation.getTranslation(at: currentTime) ?? [0, 0, 0]
                model.position = [sin(currentTime) * 2, model.position.y, -cos(currentTime) * 2]
                
//                var animation = Animation()
//                animation.rotations = generateSphereRotations()
//                model.quaternion = animation.getRotation(at: currentTime) ?? simd_quatf()
                model.rotation = [0, currentTime * 2, 0]
            } else {
                model.rotation = [0, currentTime, 0]
            }
        }
    }
    
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
        Renderer.fps = metalView.preferredFramesPerSecond // default 60 fps (11.6ms)
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
                
        let deltaTime = 1 / Float(Renderer.fps)
        update(deltaTime: deltaTime)
        
        // for later for each model that inherited from model class
//        for model in models {
//            model.update(deltaTime: deltaTime)
//        }
        
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
