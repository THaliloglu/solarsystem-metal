//
//  Skybox.metal
//  SolarSystem
//
//  Created by TOLGA HALILOGLU on 14.04.2021.
//

#include <metal_stdlib>
using namespace metal;

#import "Common.h"
struct VertexIn {
    float4 position [[ attribute(0) ]];
};

struct VertexOut {
    float4 position [[ position ]];
    float3 textureCoordinates; // When sampling texels from a cube texture, instead of using a uv coordinate, you use a 3D vector.
};

vertex VertexOut vertexSkybox(const VertexIn in [[stage_in]],
                              constant float4x4 &vp [[buffer(1)]]) {
    VertexOut out;
    out.position = (vp * in.position).xyww; // To place the sky as far away as possible, it needs to be at the very edge of NDC.
    out.textureCoordinates = in.position.xyz;
    return out;
}

fragment half4
fragmentSkybox(VertexOut in [[stage_in]],
               texturecube<half> cubeTexture
               [[texture(BufferIndexSkybox)]]) {
    constexpr sampler default_sampler(filter::linear);
    
    // You can use the skybox vertex position for the texture coordinates.
    // You don’t even need to normalize this vector to read the cube texture.
    half4 color = cubeTexture.sample(default_sampler, in.textureCoordinates);
    return color;
}

