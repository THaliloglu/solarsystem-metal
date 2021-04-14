//
//  DebugLights.metal
//  SolarSystem
//
//  Created by TOLGA HALILOGLU on 30.12.2020.
//

#include <metal_stdlib>
using namespace metal;

#import "../Metal Shaders/Common.h"

struct VertexOut {
    float4 position [[ position ]];
    float point_size [[ point_size ]];
};

vertex VertexOut vertex_light(constant float3 *vertices [[ buffer(0) ]],
                              constant Uniforms &uniforms [[ buffer(1) ]],
                              uint id [[vertex_id]])
{
    matrix_float4x4 mvp = uniforms.projectionMatrix * uniforms.viewMatrix * uniforms.modelMatrix;
    VertexOut out {
        .position = mvp * float4(vertices[id], 1),
        .point_size = 20.0
    };
    return out;
}

fragment float4 fragment_light(float2 point [[ point_coord]],
                               constant float3 &color [[ buffer(1) ]]) {
    float d = distance(point, float2(0.5, 0.5));
    if (d > 0.5) {
        discard_fragment();
    }
    return float4(color ,1);
}

