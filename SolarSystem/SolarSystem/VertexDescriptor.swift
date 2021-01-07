//
//  VertexDescriptor.swift
//  SolarSystem
//
//  Created by TOLGA HALILOGLU on 26.12.2020.
//

import ModelIO

extension MDLVertexDescriptor {
    static var defaultVertexDescriptor: MDLVertexDescriptor = {
        let vertexDescriptor = MDLVertexDescriptor()
        var offset = 0
        
        // position attribute
        vertexDescriptor.attributes[Int(Position.rawValue)] = MDLVertexAttribute(name: MDLVertexAttributePosition,
                                                            format: .float3,
                                                            offset: 0,
                                                            bufferIndex: Int(BufferIndexVertices.rawValue))
        offset += MemoryLayout<float3>.stride
        
        // normal attribute
        vertexDescriptor.attributes[Int(Normal.rawValue)] = MDLVertexAttribute(name: MDLVertexAttributeNormal,
                                                            format: .float3,
                                                            offset: offset,
                                                            bufferIndex: Int(BufferIndexVertices.rawValue))
        offset += MemoryLayout<float3>.stride
        
        // uv attribute
        vertexDescriptor.attributes[Int(UV.rawValue)] = MDLVertexAttribute(name: MDLVertexAttributeTextureCoordinate,
                                                                           format: .float2,
                                                                           offset: offset,
                                                                           bufferIndex: Int(BufferIndexVertices.rawValue))
        offset += MemoryLayout<float2>.stride
        
        vertexDescriptor.layouts[0] = MDLVertexBufferLayout(stride: offset)
        return vertexDescriptor
    }()
}
