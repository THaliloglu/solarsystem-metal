//
//  Skybox.swift
//  SolarSystem
//
//  Created by TOLGA HALILOGLU on 14.04.2021.
//

import MetalKit
class Skybox {
    struct SkySettings {
        var turbidity: Float = 0.28
        var sunElevation: Float = 0.6
        var upperAtmosphereScattering: Float = 0.1
        var groundAlbedo: Float = 4
    }
    var skySettings = SkySettings()
    
    func loadGeneratedSkyboxTexture(dimensions: SIMD2<Int32>) -> MTLTexture?
    {
        var texture: MTLTexture?
        let skyTexture = MDLSkyCubeTexture(name: "sky",
                                           channelEncoding: .uInt8,
                                           textureDimensions: dimensions,
                                           turbidity: skySettings.turbidity,
                                           sunElevation: skySettings.sunElevation,
                                           upperAtmosphereScattering: skySettings.upperAtmosphereScattering,
                                           groundAlbedo: skySettings.groundAlbedo)
        do {
            let textureLoader = MTKTextureLoader(device: Renderer.device)
            texture = try textureLoader.newTexture(texture: skyTexture, options: nil)
        } catch {
            print(error.localizedDescription)
        }
        return texture
    }
    
    
    let mesh: MTKMesh
    var texture: MTLTexture?
    let pipelineState: MTLRenderPipelineState
    let pipelineStateAA: MTLRenderPipelineState
    let depthStencilState: MTLDepthStencilState?
    
    init(textureName: String?) {
        let allocator = MTKMeshBufferAllocator(device: Renderer.device)
        let cube = MDLMesh(boxWithExtent: [1,1,1], segments: [1, 1, 1],
                           inwardNormals: true,
                           geometryType: .triangles,
                           allocator: allocator)
        do {
            mesh = try MTKMesh(mesh: cube,
                               device: Renderer.device)
        } catch {
            fatalError("failed to create skybox mesh")
        }
        
        pipelineState = Skybox.buildPipelineState(vertexDescriptor: cube.vertexDescriptor, withAntiAliasing: false)
        pipelineStateAA = Skybox.buildPipelineState(vertexDescriptor: cube.vertexDescriptor, withAntiAliasing: true)
        depthStencilState = Skybox.buildDepthStencilState()
        
        if let textureName = textureName {
            do {
                texture = try Skybox.loadCubeTexture(imageName: textureName)
            } catch {
                fatalError(error.localizedDescription)
            }
        } else {
            texture = loadGeneratedSkyboxTexture(dimensions: [256, 256])
        }
    }
    
    private static func buildPipelineState(vertexDescriptor: MDLVertexDescriptor, withAntiAliasing antialiasing: Bool) -> MTLRenderPipelineState {
        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.colorAttachments[0].pixelFormat = Renderer.colorPixelFormat
        descriptor.depthAttachmentPixelFormat = .depth32Float
        descriptor.vertexFunction = Renderer.library?.makeFunction(name: "vertexSkybox")
        descriptor.fragmentFunction = Renderer.library?.makeFunction(name: "fragmentSkybox")
        descriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(vertexDescriptor)
        descriptor.sampleCount = antialiasing ? Renderer.antialiasingSampleCount : 1
        do {
            return try Renderer.device.makeRenderPipelineState(descriptor: descriptor)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    private static func buildDepthStencilState() -> MTLDepthStencilState? {
        let descriptor = MTLDepthStencilDescriptor()
        descriptor.depthCompareFunction = .lessEqual
        descriptor.isDepthWriteEnabled = true
        return Renderer.device.makeDepthStencilState(descriptor: descriptor)
    }
    
    func render(renderEncoder: MTLRenderCommandEncoder, uniforms: Uniforms) {
        renderEncoder.pushDebugGroup("Skybox")
        renderEncoder.setRenderPipelineState(Renderer.antialiasingEnabled ? pipelineStateAA : pipelineState)
        renderEncoder.setDepthStencilState(depthStencilState)
        renderEncoder.setVertexBuffer(mesh.vertexBuffers[0].buffer, offset: 0, index: 0)
        
        var viewMatrix = uniforms.viewMatrix
        viewMatrix.columns.3 = [0, 0, 0, 1]
        var viewProjectionMatrix = uniforms.projectionMatrix * viewMatrix
        renderEncoder.setVertexBytes(&viewProjectionMatrix,
                                     length: MemoryLayout<float4x4>.stride,
                                     index: 1)
        renderEncoder.setFragmentTexture(texture,
                                         index: Int(BufferIndexSkybox.rawValue))
        
        let submesh = mesh.submeshes[0]
        renderEncoder.drawIndexedPrimitives(type: .triangle,
                                            indexCount: submesh.indexCount,
                                            indexType: submesh.indexType,
                                            indexBuffer: submesh.indexBuffer.buffer,
                                            indexBufferOffset: 0)
    }
}

extension Skybox: Texturable {}
