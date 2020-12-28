//
//  Shaders.metal
//  SolarSystem
//
//  Created by Tolga Haliloğlu on 20.12.2020.
//

#include <metal_stdlib>
using namespace metal;

#import "Common.h"

struct VertexIn {
    float4 position [[attribute(0)]];
    float3 normal [[attribute(1)]];
};

struct VertexOut {
    float4 position [[position]];
    float3 normal;
};

vertex VertexOut vertex_main(const VertexIn vertexIn [[stage_in]],
                             constant Uniforms &uniforms [[buffer(1)]])
{
    VertexOut out {
        .position = uniforms.projectionMatrix * uniforms.viewMatrix
                        * uniforms.modelMatrix * vertexIn.position,
        .normal = vertexIn.normal
    };
    return out;
}

fragment float4 fragment_main(VertexOut in [[stage_in]]) {
    return float4(in.normal, 1);
}
