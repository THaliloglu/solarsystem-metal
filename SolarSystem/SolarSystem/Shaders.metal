//
//  Shaders.metal
//  SolarSystem
//
//  Created by Tolga Haliloğlu on 20.12.2020.
//

#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float4 position [[attribute(0)]];
};

vertex float4 vertex_main(const VertexIn vertexIn [[stage_in]],
                          constant float &timer [[ buffer(1) ]]) {
    float4 position = vertexIn.position; position.y += timer;
    return position;
}

fragment float4 fragment_main() {
    return float4(1, 0, 0, 1);
}
