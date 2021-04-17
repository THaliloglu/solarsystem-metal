//
//  Texturable.swift
//  SolarSystem
//
//  Created by TOLGA HALILOGLU on 1.01.2021.
//

import MetalKit

protocol Texturable {}

extension Texturable {
    static func loadTexture(imageName: String) throws -> MTLTexture? {
        let textureLoader = MTKTextureLoader(device: Renderer.device)
        
        let textureLoaderOptions: [MTKTextureLoader.Option: Any] =
            [.origin: MTKTextureLoader.Origin.bottomLeft,
             .SRGB: false,
             .generateMipmaps: NSNumber(booleanLiteral: true)]
        
        let fileExtension =
            URL(fileURLWithPath: imageName).pathExtension.isEmpty ?
            "png" : nil
        
        guard let url = Bundle.main.url(forResource: imageName,
                                        withExtension: fileExtension)
        else {
            do {
                let texture = try textureLoader.newTexture(name: imageName,
                                                           scaleFactor: 1.0,
                                                           bundle: Bundle.main, options: nil)
                print("loaded: \(imageName) from asset catalog")
                return texture
            } catch let error {
                print("Texture not found: \(imageName) error: \(error.localizedDescription)")
                return nil
            }
        }
        
        let texture = try textureLoader.newTexture(URL: url,
                                                   options: textureLoaderOptions)
        print("loaded texture: \(url.lastPathComponent)")
        return texture
    }
    
    static func loadTexture(texture: MDLTexture) throws -> MTLTexture? {
        let textureLoader = MTKTextureLoader(device: Renderer.device)
        let textureLoaderOptions: [MTKTextureLoader.Option: Any] =
            [.origin: MTKTextureLoader.Origin.bottomLeft,
             .SRGB: false,
             .generateMipmaps: NSNumber(booleanLiteral: true)]
        
        let texture = try? textureLoader.newTexture(texture: texture,
                                                    options: textureLoaderOptions)
        print("loaded texture from MDLTexture")
        return texture
    }
    
    static func loadCubeTexture(imageName: String) throws -> MTLTexture {
        let textureLoader = MTKTextureLoader(device: Renderer.device)
        if let texture = MDLTexture(cubeWithImagesNamed: [imageName]) {
            let options: [MTKTextureLoader.Option: Any] =
                [.origin: MTKTextureLoader.Origin.topLeft,
                 .SRGB: false,
                 .generateMipmaps: NSNumber(booleanLiteral: false)]
            return try textureLoader.newTexture(texture: texture, options: options)
        }
        let texture = try textureLoader.newTexture(name: imageName, scaleFactor: 1.0,
                                                   bundle: .main)
        return texture
    }
}
