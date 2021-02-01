//
//  Shaders.metal
//  SolarSystem
//
//  Created by Tolga Haliloğlu on 20.12.2020.
//

#include <metal_stdlib>
using namespace metal;

#import "Common.h"

constant bool hasColorTexture [[function_constant(0)]];
constant bool hasNormalTexture [[function_constant(1)]];
constant bool hasAmbientTexture [[function_constant(2)]];
constant bool hasSpecularTexture [[function_constant(3)]];
constant bool hasRoughnessTexture [[function_constant(4)]];

struct VertexIn {
    float4 position [[attribute(0)]];
    float3 normal [[attribute(1)]];
    float2 uv [[attribute(UV)]];
    float3 tangent [[attribute(Tangent)]];
    float3 bitangent [[attribute(Bitangent)]];
};

struct VertexOut {
    float4 position [[position]];
    float3 worldPosition;
    float3 worldNormal;
    float2 uv;
    float3 worldTangent;
    float3 worldBitangent;
};

vertex VertexOut vertex_main(const VertexIn vertexIn [[stage_in]],
                             constant Uniforms &uniforms [[buffer(BufferIndexUniforms)]])
{
    VertexOut out {
        .position = uniforms.projectionMatrix * uniforms.viewMatrix
        * uniforms.modelMatrix * vertexIn.position,
        .worldPosition = (uniforms.modelMatrix * vertexIn.position).xyz,
        .worldNormal = uniforms.normalMatrix * vertexIn.normal,
        .uv = vertexIn.uv,
        .worldTangent = uniforms.normalMatrix * vertexIn.tangent,
        .worldBitangent = uniforms.normalMatrix * vertexIn.bitangent,
    };
    return out;
}

fragment float4 fragment_main(VertexOut in [[stage_in]],
                              texture2d<float> baseColorTexture [[texture(BaseColorTexture), function_constant(hasColorTexture)]],
                              texture2d<float> normalTexture [[texture(NormalTexture), function_constant(hasNormalTexture)]],
                              texture2d<float> ambientTexture [[texture(AmbientTexture), function_constant(hasAmbientTexture)]],
                              texture2d<float> specularTexture [[texture(SpecularTexture), function_constant(hasSpecularTexture)]],
                              texture2d<float> RoughnessTexture [[texture(RoughnessTexture), function_constant(hasRoughnessTexture)]],
                              constant Light *lights [[buffer(BufferIndexLights)]],
                              constant FragmentUniforms &fragmentUniforms [[buffer(BufferIndexFragmentUniforms)]],
                              constant Material &material [[buffer(BufferIndexMaterials)]],
                              sampler textureSampler [[sampler(0)]]) {
    float3 baseColor;
    if (hasColorTexture) {
        baseColor = baseColorTexture.sample(textureSampler, in.uv * fragmentUniforms.tiling).rgb;
    } else {
        baseColor = material.baseColor;
    }
    
    float3 normalValue;
    if (hasNormalTexture) {
        normalValue = normalTexture.sample(textureSampler, in.uv * fragmentUniforms.tiling).rgb;
        normalValue = normalValue * 2 - 1;
    } else {
        normalValue = in.worldNormal;
    }
    normalValue = normalize(normalValue);
    
    float3 ambientColor = 0;
    float3 specularColor = 0;
    float materialShininess = material.shininess;
        
    float3 diffuseColor = 0;
    
    float3 normalDirection = float3x3(in.worldTangent, in.worldBitangent, in.worldNormal) * normalValue;
    normalDirection = normalize(normalDirection);

    for (uint i = 0; i < fragmentUniforms.lightCount; i++) {
        Light light = lights[i];
        if (light.type == Sunlight) {
            float3 lightDirection = normalize(-light.position);
            float diffuseIntensity = saturate(-dot(lightDirection, normalDirection));
            diffuseColor += light.color * baseColor * diffuseIntensity;
            
            if (diffuseIntensity > 0) {
                float3 reflection = reflect(lightDirection, normalDirection);
                float3 cameraDirection = normalize(in.worldPosition - fragmentUniforms.cameraPosition);
                float specularIntensity = pow(saturate(-dot(reflection, cameraDirection)), materialShininess);
                
                float3 materialSpecularColor;
                if (hasSpecularTexture) {
                    materialSpecularColor = specularTexture.sample(textureSampler, in.uv * fragmentUniforms.tiling).rgb;
                } else {
                    materialSpecularColor = material.specularColor;
                }
                specularColor += light.specularColor * materialSpecularColor * specularIntensity;
            } else {
                if (hasAmbientTexture) {
                    ambientColor = ambientTexture.sample(textureSampler, in.uv * fragmentUniforms.tiling).rgb;
                } else {
                    ambientColor = material.ambientOcclusion;
                }
            }
        } else if (light.type == Ambientlight) {
            ambientColor += light.color * light.intensity;
        } else if (light.type == Pointlight) {
            float d = distance(light.position, in.worldPosition);
            float3 lightDirection = normalize(in.worldPosition - light.position);
            float attenuation = 1.0 / (light.attenuation.x + light.attenuation.y * d + light.attenuation.z * d * d);
            float diffuseIntensity = saturate(-dot(lightDirection, normalDirection));
            float3 color = light.color * baseColor * diffuseIntensity;
            color *= attenuation;
            diffuseColor += color;
        } else if (light.type == Spotlight) {
            float d = distance(light.position, in.worldPosition);
            float3 lightDirection = normalize(in.worldPosition - light.position);
            float3 coneDirection = normalize(light.coneDirection);
            float spotResult = dot(lightDirection, coneDirection);
            if (spotResult > cos(light.coneAngle)) {
                float attenuation = 1.0 / (light.attenuation.x + light.attenuation.y * d + light.attenuation.z * d * d);
                attenuation *= pow(spotResult, light.coneAttenuation);
                float diffuseIntensity = saturate(dot(-lightDirection, normalDirection));
                float3 color = light.color * baseColor * diffuseIntensity;
                color *= attenuation;
                diffuseColor += color;
            }
        }
    }
    float3 color = diffuseColor + ambientColor + specularColor;
    return float4(color, 1);
}
