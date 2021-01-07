//
//  Texturable.swift
//  SolarSystem
//
//  Created by TOLGA HALILOGLU on 1.01.2021.
//

import MetalKit

protocol Texturable {
    
}

extension Texturable {
    static func loadTexture(imageName: String) throws -> MTLTexture?
    {
        let textureLoader = MTKTextureLoader(device: Renderer.device)
        let textureLoaderOptions: [MTKTextureLoader.Option: Any] = [.origin: MTKTextureLoader.Origin.bottomLeft,
                                                                    .SRGB:false,
                                                                    .generateMipmaps: NSNumber(booleanLiteral: true)
        ]
        
        let fileExtension = URL(fileURLWithPath: imageName).pathExtension.isEmpty ? "png" : nil
        guard let url = Bundle.main.url(forResource: imageName,
                                        withExtension: fileExtension)
        else {
            print("Failed to load \(imageName)\n - loading from Assets Catalog")
            return try textureLoader.newTexture(name: imageName,
                                                scaleFactor: 1.0,
                                                bundle: Bundle.main,
                                                options: nil)
        }
        
        let texture = try textureLoader.newTexture(URL: url,
                                                   options: textureLoaderOptions)
        
        print("loaded texture: \(url.lastPathComponent)")
        return texture
    }
}
