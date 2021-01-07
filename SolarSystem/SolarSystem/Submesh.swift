//
//  Submesh.swift
//  SolarSystem
//
//  Created by TOLGA HALILOGLU on 26.12.2020.
//

import MetalKit

class Submesh {
    struct Textures {
        let baseColor: MTLTexture?
    }
    
    let textures: Textures
    var mtkSubmesh: MTKSubmesh
    
    init(mdlSubmesh: MDLSubmesh, mtkSubmesh: MTKSubmesh) {
        self.mtkSubmesh = mtkSubmesh
        textures = Textures(material: mdlSubmesh.material)
    }
}

extension Submesh: Texturable {}

private extension Submesh.Textures {
    init(material: MDLMaterial?) {
        func property(with semantic: MDLMaterialSemantic) -> MTLTexture? {
            guard
                let property = material?.property(with: semantic),
                property.type == .string,
                let filename = property.stringValue,
                let texture = try? Submesh.loadTexture(imageName: filename)
            else {
                return nil
            }
            return texture
        }
        baseColor = property(with: MDLMaterialSemantic.baseColor)
    }
}
