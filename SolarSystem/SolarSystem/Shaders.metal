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
    float3 worldPosition;
    float3 worldNormal;
};

vertex VertexOut vertex_main(const VertexIn vertexIn [[stage_in]],
                             constant Uniforms &uniforms [[buffer(1)]])
{
    VertexOut out {
        .position = uniforms.projectionMatrix * uniforms.viewMatrix
                        * uniforms.modelMatrix * vertexIn.position,
        .worldPosition = (uniforms.modelMatrix * vertexIn.position).xyz,
        .worldNormal = uniforms.normalMatrix * vertexIn.normal
    };
    return out;
}

fragment float4 fragment_main(VertexOut in [[stage_in]],
                              constant Light *lights [[buffer(2)]],
                              constant FragmentUniforms &fragmentUniforms [[buffer(3)]]) {
    float3 baseColor = float3(0, 0, 1);
    float3 diffuseColor = 0;
    
    float3 normalDirection = normalize(in.worldNormal);
    
    for (uint i = 0; i < fragmentUniforms.lightCount; i++) {
        Light light = lights[i];
        if (light.type == Sunlight) {
            float3 lightDirection = normalize(-light.position);
            float diffuseIntensity = saturate(-dot(lightDirection, normalDirection));
            diffuseColor += light.color * baseColor * diffuseIntensity;
        }
    }
    float3 color = diffuseColor;
    return float4(color, 1);
}
