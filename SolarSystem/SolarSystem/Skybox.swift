//
//  Skybox.swift
//  SolarSystem
//
//  Created by TOLGA HALILOGLU on 14.04.2021.
//

import MetalKit
class Skybox {
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
        
        let submesh = mesh.submeshes[0]
        renderEncoder.drawIndexedPrimitives(type: .triangle,
                                            indexCount: submesh.indexCount,
                                            indexType: submesh.indexType,
                                            indexBuffer: submesh.indexBuffer.buffer,
                                            indexBufferOffset: 0)
    }
}
