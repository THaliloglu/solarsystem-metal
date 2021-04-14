//
//  Submesh.swift
//  SolarSystem
//
//  Created by TOLGA HALILOGLU on 26.12.2020.
//

import MetalKit

class Submesh {
    var mtkSubmesh: MTKSubmesh
    
    let material: Material
    
    struct Textures {
        let baseColor: MTLTexture?
        let normal: MTLTexture?
        let ambient: MTLTexture?
        let specular: MTLTexture?
        let roughness: MTLTexture?
    }
    
    let textures: Textures
    let pipelineState: MTLRenderPipelineState
    let pipelineStateAA: MTLRenderPipelineState
    
    init(mdlSubmesh: MDLSubmesh,
         mtkSubmesh: MTKSubmesh,
         vertexFunctionName: String,
         fragmentFunctionName: String) {
        self.mtkSubmesh = mtkSubmesh
        textures = Textures(material: mdlSubmesh.material)
        pipelineState = Submesh.makePipelineState(textures: textures,
                                                  vertexFunctionName: vertexFunctionName,
                                                  fragmentFunctionName: fragmentFunctionName,
                                                  withAntiAliasing: false)
        pipelineStateAA = Submesh.makePipelineState(textures: textures,
                                                    vertexFunctionName: vertexFunctionName,
                                                    fragmentFunctionName: fragmentFunctionName,
                                                    withAntiAliasing: true)
        material = Material(material: mdlSubmesh.material)
    }
}

// Pipeline state
private extension Submesh {
    static func makePipelineState(textures: Textures,
                                  vertexFunctionName: String,
                                  fragmentFunctionName: String,
                                  withAntiAliasing antialiasing: Bool) -> MTLRenderPipelineState {
        let functionConstants = makeFunctionConstants(textures: textures)
        let library = Renderer.library
        let vertexFunction = library?.makeFunction(name: vertexFunctionName)
        
        let fragmentFunction: MTLFunction?
        do {
            fragmentFunction = try library?.makeFunction(name: fragmentFunctionName, constantValues: functionConstants)  
        } catch {
            fatalError("No Metal function exists")
        }
        
        var pipelineState: MTLRenderPipelineState
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        
        let vertexDescriptor = Model.vertexDescriptor
        pipelineDescriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(vertexDescriptor)
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
    
    static func makeFunctionConstants(textures: Textures) -> MTLFunctionConstantValues {
        let functionConstants = MTLFunctionConstantValues()
        
        var property = textures.baseColor != nil
        functionConstants.setConstantValue(&property,
                                           type: .bool,
                                           index: 0)
        
        property = textures.normal != nil
        functionConstants.setConstantValue(&property,
                                           type: .bool,
                                           index: 1)
        
        property = textures.ambient != nil
        functionConstants.setConstantValue(&property,
                                           type: .bool,
                                           index: 2)
        
        property = textures.specular != nil
        functionConstants.setConstantValue(&property,
                                           type: .bool,
                                           index: 3)
        
        property = textures.roughness != nil
        functionConstants.setConstantValue(&property,
                                           type: .bool,
                                           index: 4)
        
        // MARK: - For PBR shading
        // - hasMetallicTexture
        // - hasAOTexture
//        property = false
//        functionConstants.setConstantValue(&property,
//                                           type: .bool,
//                                           index: 3)
//        functionConstants.setConstantValue(&property,
//                                           type: .bool,
//                                           index: 4)
        
        return functionConstants
    }
}

extension Submesh: Texturable {}

private extension Submesh.Textures {
    init(material: MDLMaterial?) {
        func property(with semantic: MDLMaterialSemantic) -> MTLTexture? {
            guard let property = material?.property(with: semantic),
                  property.type == .string,
                  let filename = property.stringValue,
                  let texture = try? Submesh.loadTexture(imageName: filename)
            else {
                if let property = material?.property(with: semantic),
                   property.type == .texture,
                   let mdlTexture = property.textureSamplerValue?.texture {
                    return try? Submesh.loadTexture(texture: mdlTexture)
                }
                return nil
            }
            return texture
        }
        baseColor = property(with: .baseColor)
        normal = property(with: .tangentSpaceNormal)
        ambient = property(with: .ambientOcclusion)
        specular = property(with: .specular)
        roughness = property(with: .roughness)
    }
}

private extension Material {
    init(material: MDLMaterial?) {
        self.init()
        
        if let baseColor = material?.property(with: .baseColor),
           baseColor.type == .float3 {
            self.baseColor = baseColor.float3Value
        }
        if let ambient = material?.property(with: .ambientOcclusion),
           ambient.type == .float3 {
            self.ambientOcclusion = ambient.float3Value
        }
        if let specular = material?.property(with: .specular),
           specular.type == .float3 {
            self.specularColor = specular.float3Value
        }
        if let shininess = material?.property(with: .specularExponent),
           shininess.type == .float {
            self.shininess = shininess.floatValue
        }
        if let roughness = material?.property(with: .roughness),
           roughness.type == .float3 {
            self.roughness = roughness.floatValue
        }
    }
}
