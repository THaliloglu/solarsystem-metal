//
//  Nature.swift
//  SolarSystem
//
//  Created by TOLGA HALILOGLU on 10.05.2021.
//

import MetalKit

class Nature: Node {
    let instanceCount: Int
    let instanceBuffer: MTLBuffer
    let pipelineState: MTLRenderPipelineState
    let pipelineStateAA: MTLRenderPipelineState
    
    let morphTargetCount: Int
    let textureCount: Int
    
    let vertexBuffer: MTLBuffer
    let submesh: MTKSubmesh?
    
    var vertexCount: Int
    
    static let mdlVertexDescriptor: MDLVertexDescriptor = {
        let vertexDescriptor = MDLVertexDescriptor()
        var offset = 0
        let packedFloat3Size = MemoryLayout<Float>.stride * 3
        vertexDescriptor.attributes[Int(Position.rawValue)] =
            MDLVertexAttribute(name: MDLVertexAttributePosition,
                               format: .float3,
                               offset: offset, bufferIndex: 0)
        offset += packedFloat3Size
        vertexDescriptor.attributes[Int(Normal.rawValue)] =
            MDLVertexAttribute(name: MDLVertexAttributeNormal,
                               format: .float3,
                               offset: offset, bufferIndex: 0)
        offset += packedFloat3Size
        vertexDescriptor.attributes[Int(UV.rawValue)] =
            MDLVertexAttribute(name: MDLVertexAttributeTextureCoordinate,
                               format: .float2,
                               offset: offset, bufferIndex: 0)
        offset += MemoryLayout<float2>.stride
        vertexDescriptor.layouts[0] = MDLVertexBufferLayout(stride: offset)
        print("Vertex descriptor stride: \((vertexDescriptor.layouts[0] as! MDLVertexBufferLayout).stride) bytes")
        return vertexDescriptor
    }()
    
    static let mtlVertexDescriptor: MTLVertexDescriptor = {
        return MTKMetalVertexDescriptorFromModelIO(Nature.mdlVertexDescriptor)!
    }()
    
    let baseColorTexture: MTLTexture?
    
    init(name: String,
         instanceCount: Int = 1,
         textureNames: [String] = [],
         morphTargetNames: [String] = []
    ) {
        
        morphTargetCount = morphTargetNames.count
        textureCount = textureNames.count
        
        // load up the first morph target into a buffer
        // assume only one vertex buffer and one material submesh for simplicity
        guard let mesh = Nature.loadMesh(name: morphTargetNames[0]) else {
            fatalError("morph target not loaded")
        }
        submesh = Nature.loadSubmesh(mesh: mesh)

        let bufferLength = mesh.vertexBuffers[0].buffer.length
        vertexBuffer = Renderer.device.makeBuffer(length: bufferLength * morphTargetNames.count)!
        
        // create the pipeline state
        let library = Renderer.library
        guard let vertexFunction = library?.makeFunction(name: "vertex_nature"),
              let fragmentFunction = library?.makeFunction(name: "fragment_nature") else {
            fatalError("failed to create functions")
        }
        pipelineState = Nature.makePipelineState(vertex: vertexFunction,
                                                 fragment: fragmentFunction, withAntiAliasing: false)
        pipelineStateAA = Nature.makePipelineState(vertex: vertexFunction,
                                                   fragment: fragmentFunction, withAntiAliasing: true)
        
        // load the instances
        self.instanceCount = instanceCount
        instanceBuffer = Nature.buildInstanceBuffer(instanceCount: instanceCount)
        
        let layout = mesh.vertexDescriptor.layouts[0] as! MDLVertexBufferLayout
        vertexCount = bufferLength / layout.stride
        
        let commandBuffer = Renderer.commandQueue.makeCommandBuffer()
        let blitEncoder = commandBuffer?.makeBlitCommandEncoder()
        
        for i in 0..<morphTargetNames.count {
            guard let mesh = Nature.loadMesh(name: morphTargetNames[i]) else {
                fatalError("morph target not loaded")
            }
            
            let buffer = mesh.vertexBuffers[0].buffer
            blitEncoder?.copy(from: buffer,
                              sourceOffset: 0,
                              to: vertexBuffer,
                              destinationOffset: buffer.length * i,
                              size: buffer.length)
        }
        blitEncoder?.endEncoding()
        commandBuffer?.commit()
        
        // load the texture
        baseColorTexture = Nature.loadTextureArray(textureNames: textureNames)
        
        super.init()
        
        // initialize the instance buffer in case there is only one instance
        // (there is no array of Transforms in this class)
        updateBuffer(instance: 0, transform: Transform(), textureID: 0, morphTargetID: 0)
        self.name = name
    }
    
    static func loadSubmesh(mesh: MTKMesh) -> MTKSubmesh {
        guard let submesh = mesh.submeshes.first else {
            fatalError("No submesh found")
        }
        return submesh
    }
    
    static func buildInstanceBuffer(instanceCount: Int) -> MTLBuffer {
        guard let instanceBuffer =
                Renderer.device.makeBuffer(length: MemoryLayout<NatureInstance>.stride * instanceCount,
                                           options: []) else {
            fatalError("Failed to create instance buffer")
        }
        return instanceBuffer
    }
    
    func updateBuffer(instance: Int, transform: Transform,
                      textureID: Int, morphTargetID: Int) {
        guard textureID < textureCount
                && morphTargetID < morphTargetCount else {
          fatalError("ID is too high")
        }
        
        var pointer =
            instanceBuffer.contents().bindMemory(to: NatureInstance.self,
                                                 capacity: instanceCount)
        pointer = pointer.advanced(by: instance)
        pointer.pointee.textureID = UInt32(textureID)
        pointer.pointee.morphTargetID = UInt32(morphTargetID)
        pointer.pointee.modelMatrix = transform.modelMatrix
        pointer.pointee.normalMatrix = transform.normalMatrix
    }
    
    static func loadMesh(name: String) -> MTKMesh? {
        let assetURL = Bundle.main.url(forResource: name, withExtension: "obj")!
        let allocator = MTKMeshBufferAllocator(device: Renderer.device)
        let asset = MDLAsset(url: assetURL,
                             vertexDescriptor: mdlVertexDescriptor,
                             bufferAllocator: allocator)
        let mdlMesh = asset.object(at: 0) as! MDLMesh
        return try? MTKMesh(mesh: mdlMesh, device: Renderer.device)
    }
    
    static func makePipelineState(vertex: MTLFunction,
                                  fragment: MTLFunction,
                                  withAntiAliasing antialiasing: Bool) -> MTLRenderPipelineState {
        
        var pipelineState: MTLRenderPipelineState
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertex
        pipelineDescriptor.fragmentFunction = fragment
        
        pipelineDescriptor.vertexDescriptor = Nature.mtlVertexDescriptor
        pipelineDescriptor.colorAttachments[0].pixelFormat = Renderer.colorPixelFormat
        pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
        pipelineDescriptor.sampleCount = antialiasing ? Renderer.antialiasingSampleCount : 1
        do {
            pipelineState = try Renderer.device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch let error {
            fatalError(error.localizedDescription)
        }
        return pipelineState
    }
    
}


extension Nature: Texturable {}

extension Nature: Renderable {
    func render(renderEncoder: MTLRenderCommandEncoder, uniforms vertex: Uniforms, fragmentUniforms fragment: FragmentUniforms) {
        guard let submesh = submesh else { return }
        var uniforms = vertex
        var fragmentUniforms = fragment
        uniforms.modelMatrix = worldTransform
        uniforms.normalMatrix = float3x3(normalFrom4x4: modelMatrix)
        
        renderEncoder.setRenderPipelineState(Renderer.antialiasingEnabled ? pipelineStateAA : pipelineState)
        
        renderEncoder.setVertexBytes(&uniforms,
                                     length: MemoryLayout<Uniforms>.stride,
                                     index: Int(BufferIndexUniforms.rawValue))
        renderEncoder.setVertexBuffer(instanceBuffer, offset: 0,
                                      index: Int(BufferIndexInstances.rawValue))
        
        renderEncoder.setVertexBytes(&vertexCount,
                                     length: MemoryLayout<Int>.stride,
                                     index: 1)
        // set vertex buffer
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        
        renderEncoder.setFragmentBytes(&fragmentUniforms,
                                       length: MemoryLayout<FragmentUniforms>.stride,
                                       index: Int(BufferIndexFragmentUniforms.rawValue))
        renderEncoder.setFragmentTexture(baseColorTexture, index: 0)
        renderEncoder.drawIndexedPrimitives(type: .triangle,
                                            indexCount: submesh.indexCount,
                                            indexType: submesh.indexType,
                                            indexBuffer: submesh.indexBuffer.buffer,
                                            indexBufferOffset: submesh.indexBuffer.offset,
                                            instanceCount:  instanceCount)
    }
}

