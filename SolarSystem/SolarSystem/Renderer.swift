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
    
    let depthStencilState: MTLDepthStencilState
    static func buildDepthStencilState() -> MTLDepthStencilState? {
        let descriptor = MTLDepthStencilDescriptor()
        descriptor.depthCompareFunction = .less
        descriptor.isDepthWriteEnabled = true
        return Renderer.device.makeDepthStencilState(descriptor: descriptor)
    }
    
    lazy var sunlight: Light = {
        var light = buildDefaultLight()
        light.position = [0, 2, -2]
        return light
    }()
    
    lazy var ambientLight: Light = {
        var light = buildDefaultLight()
        light.color = [0.5, 1, 0]
        light.intensity = 0.2
        light.type = Ambientlight
        return light
    }()
    
    lazy var redLight: Light = {
        var light = buildDefaultLight()
        light.position = [-1.4, 0, 0]
        light.color = [1, 0, 0]
        light.attenuation = float3(1, 3, 4)
        light.type = Pointlight
        return light
    }()
    
    lazy var spotlight: Light = {
        var light = buildDefaultLight()
        light.position = [1.4, 0, 0]
        light.color = [1, 0, 1]
        light.attenuation = float3(1, 0.5, 0)
        light.type = Spotlight
        light.coneAngle = Float(40).degreesToRadians
        light.coneDirection = [-2, 0, -1.5]
        light.coneAttenuation = 12
        return light
    }()
    
    var lights: [Light] = []
    
    func buildDefaultLight() -> Light {
        var light = Light()
        light.position = [0, 0, 0]
        light.color = [1, 1, 1]
        light.specularColor = [0.6, 0.6, 0.6]
        light.intensity = 1
        light.attenuation = float3(1, 0, 0)
        light.type = Sunlight
        return light
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
        metalView.device = device
        metalView.depthStencilPixelFormat = .depth32Float
        depthStencilState = Renderer.buildDepthStencilState()!
        
        super.init()
        
        metalView.clearColor = MTLClearColor(red: 1.0, green: 1.0,
                                             blue: 0.8, alpha: 1.0)
        metalView.delegate = self
        
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
        
        lights.append(sunlight)
        lights.append(ambientLight)
        lights.append(redLight)
        lights.append(spotlight)
        
        fragmentUniforms.lightCount = UInt32(lights.count)
        
        mtkView(metalView, drawableSizeWillChange: metalView.bounds.size)
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
        
        renderEncoder.setFragmentBytes(&lights, length: MemoryLayout<Light>.stride * lights.count, index: 2)
        renderEncoder.setFragmentBytes(&fragmentUniforms, length: MemoryLayout<FragmentUniforms>.stride, index: 3)
        
        // render all the models in the array
        for model in models {
            
            if model.name != "SpherePrimitive" {
                timer += 0.005
                model.position = [sin(timer) * 2, model.position.y, -cos(timer) * 2]
                model.rotation = [0, timer * 2, 0]
            } else {
                model.rotation = [0, timer, 0]
            }
            
            uniforms.modelMatrix = model.modelMatrix
            uniforms.normalMatrix = uniforms.modelMatrix.upperLeft
            
            renderEncoder.setVertexBytes(&uniforms, length: MemoryLayout<Uniforms>.stride, index: 1)
            renderEncoder.setRenderPipelineState(model.pipelineState)
            
            for mesh in model.meshes {
                let vertexBuffer = mesh.mtkMesh.vertexBuffers[0].buffer
                renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
                
                for submesh in mesh.submeshes {
                    let mtkSubmesh = submesh.mtkSubmesh
                    renderEncoder.drawIndexedPrimitives(type: .triangle,
                                                        indexCount: mtkSubmesh.indexCount,
                                                        indexType: mtkSubmesh.indexType,
                                                        indexBuffer: mtkSubmesh.indexBuffer.buffer,
                                                        indexBufferOffset: mtkSubmesh.indexBuffer.offset)
                }
            }
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
