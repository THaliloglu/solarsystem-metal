//
//  Mesh.swift
//  SolarSystem
//
//  Created by TOLGA HALILOGLU on 26.12.2020.
//

import MetalKit

struct Mesh {
    let mtkMesh: MTKMesh
    let submeshes: [Submesh]
    
    init(mdlMesh: MDLMesh, mtkMesh: MTKMesh,
         vertexFunctionName: String,
         fragmentFunctionName: String) {
        self.mtkMesh = mtkMesh
        submeshes = zip(mdlMesh.submeshes!, mtkMesh.submeshes).map { mesh in
            Submesh(mdlSubmesh: mesh.0 as! MDLSubmesh, mtkSubmesh: mesh.1,
                    vertexFunctionName: vertexFunctionName,
                    fragmentFunctionName: fragmentFunctionName)
        }
    }
}
