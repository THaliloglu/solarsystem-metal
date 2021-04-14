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
};

vertex VertexOut vertexSkybox(const VertexIn in [[stage_in]],
                              constant float4x4 &vp [[buffer(1)]]) {
    VertexOut out;
    out.position = (vp * in.position).xyww; // To place the sky as far away as possible, it needs to be at the very edge of NDC.
    return out;
}

fragment half4 fragmentSkybox(VertexOut in [[stage_in]]) {
    return half4(1, 1, 0, 1);
}
