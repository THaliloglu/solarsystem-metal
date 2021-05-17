//
//  Common.h
//  SolarSystem
//
//  Created by TOLGA HALILOGLU on 22.12.2020.
//

#ifndef Common_h
#define Common_h

#import <simd/simd.h>

typedef struct {
    matrix_float4x4 modelMatrix;
    matrix_float4x4 viewMatrix;
    matrix_float4x4 projectionMatrix;
    matrix_float3x3 normalMatrix;
} Uniforms;

typedef enum {
    unused = 0,
    Sunlight = 1,
    Spotlight = 2,
    Pointlight = 3,
    Ambientlight = 4
} LightType;

typedef struct {
    vector_float3 position;
    vector_float3 color;
    vector_float3 specularColor;
    float intensity;
    vector_float3 attenuation;
    LightType type;
    float coneAngle;
    vector_float3 coneDirection;
    float coneAttenuation;
} Light;

typedef struct {
    uint lightCount;
    vector_float3 cameraPosition;
    uint tiling;
} FragmentUniforms;

typedef enum {
    Position = 0,
    Normal = 1,
    UV = 2,
    Tangent = 3,
    Bitangent = 4
} Attributes;

typedef enum {
    BufferIndexVertices = 0,
    BufferIndexUniforms = 11,
    BufferIndexLights = 12,
    BufferIndexFragmentUniforms = 13,
    BufferIndexMaterials = 14,
    BufferIndexInstances = 15,
    BufferIndexSkybox = 20
} BufferIndices;

typedef enum {
    BaseColorTexture = 0,
    NormalTexture = 1,
    AmbientTexture = 2,
    SpecularTexture = 3,
    RoughnessTexture = 4
} Textures;

typedef struct {
    vector_float3 baseColor;
    vector_float3 specularColor;
    float roughness;
    float metallic;
    vector_float3 ambientOcclusion;
    float shininess;
} Material;

struct Instances {
    matrix_float4x4 modelMatrix;
    matrix_float3x3 normalMatrix;
};

struct NatureInstance {
    uint textureID;
    uint morphTargetID;
    matrix_float4x4 modelMatrix;
    matrix_float3x3 normalMatrix;
};

#endif /* Common_h */
