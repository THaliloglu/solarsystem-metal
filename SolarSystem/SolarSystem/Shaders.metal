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
};

struct VertexOut {
    float4 position [[position]];
    float point_size [[point_size]];
};

vertex float4 vertex_main(const VertexIn vertexIn [[stage_in]],
                          constant Uniforms &uniforms [[buffer(1)]])
{
    float4 position = uniforms.projectionMatrix * uniforms.viewMatrix * uniforms.modelMatrix * vertexIn.position;
    return position;
}

//vertex VertexOut vertex_main(const VertexIn vertexIn [[stage_in]],
//                             constant float &timer [[ buffer(1) ]]) {
//    float4 position = vertexIn.position;
//    position.y += timer;
//
//    VertexOut vertex_out {
//        .position = position,
//        .point_size = 20.0
//    };
//    return vertex_out;
//}

fragment float4 fragment_main(constant float4 &color [[buffer(0)]]) {
    return color;
}
