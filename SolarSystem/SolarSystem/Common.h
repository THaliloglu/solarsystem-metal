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
} FragmentUniforms;

typedef enum {
    Position = 0,
    Normal = 1,
    UV = 2
} Attributes;

typedef enum {
    BufferIndexVertices = 0,
    BufferIndexUniforms = 1,
    BufferIndexLights = 2,
    BufferIndexFragmentUniforms = 3
} BufferIndices;

typedef enum {
    BaseColorTexture = 0
} Textures;

#endif /* Common_h */
