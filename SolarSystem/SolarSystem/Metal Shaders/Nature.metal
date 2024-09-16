//
//  Nature.metal
//  SolarSystem
//
//  Created by TOLGA HALILOGLU on 10.05.2021.
//

#include <metal_stdlib>
using namespace metal;
#import "Common.h"


struct VertexIn {
    packed_float3 position;
    packed_float3 normal;
    float2 uv;
};

struct VertexOut {
    float4 position [[position]];
    float3 worldPosition;
    float3 worldNormal;
    float2 uv;
    uint32_t textureID [[flat]];
};

vertex VertexOut vertex_nature(constant VertexIn *in [[buffer(0)]],
                               uint32_t vertexID [[vertex_id]],
                               constant Uniforms &uniforms [[buffer(BufferIndexUniforms)]],
                               constant NatureInstance *instances [[buffer(BufferIndexInstances)]],
                               uint32_t instanceID [[instance_id]],
                               constant int &vertexCount [[buffer(1)]]) {
    NatureInstance instance = instances[instanceID];
    uint32_t offset = instance.morphTargetID * vertexCount;
    VertexIn vertexIn = in[vertexID + offset];
    
    VertexOut out;
    float4 position = float4(vertexIn.position, 1);
    float3 normal = vertexIn.normal;
    
    out.position = uniforms.projectionMatrix * uniforms.viewMatrix
    * uniforms.modelMatrix * instance.modelMatrix * position;
    out.worldPosition = (uniforms.modelMatrix * position
                         * instance.modelMatrix).xyz;
    out.worldNormal = uniforms.normalMatrix * instance.normalMatrix * normal;
    out.uv = vertexIn.uv;
    out.textureID = instance.textureID;
    return out;
}

constant float3 sunlight = float3(2, 4, -4);

fragment float4 fragment_nature(VertexOut in [[stage_in]],
                                texture2d_array<float> baseColorTexture [[texture(0)]],
                                constant FragmentUniforms &fragmentUniforms [[buffer(BufferIndexFragmentUniforms)]]
                                ){
    constexpr sampler s(filter::linear);
    float4 baseColor = baseColorTexture.sample(s, in.uv, in.textureID);
    float3 normal = normalize(in.worldNormal);
    
    float3 lightDirection = normalize(sunlight);
    float diffuseIntensity = saturate(dot(lightDirection, normal));
    float4 color = mix(baseColor*0.5, baseColor*1.5, diffuseIntensity);
    return color;
}
