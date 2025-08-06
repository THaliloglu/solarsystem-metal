//
//  Renderer.swift
//  SolarSystem
//
//  Created by Tolga Haliloğlu on 20.12.2020.
//

import MetalKit
class Renderer: NSObject {
  
  static var device: MTLDevice!
  static var commandQueue: MTLCommandQueue!
  static var library: MTLLibrary!
  static var colorPixelFormat: MTLPixelFormat!
  
  var scene: MetalScene?
  
  let depthStencilState: MTLDepthStencilState
  static func buildDepthStencilState() -> MTLDepthStencilState? {
    let descriptor = MTLDepthStencilDescriptor()
    descriptor.depthCompareFunction = .less
    descriptor.isDepthWriteEnabled = true
    return Renderer.device.makeDepthStencilState(descriptor: descriptor)
  }
  
  static var antialiasingSampleCount = 4
  static var antialiasingEnabled = true
  
  // Debug drawing of lights
  lazy var lightPipelineState: MTLRenderPipelineState = {
    return buildLightPipelineState()
  }()
  
  var shadowTexture: MTLTexture?
  let shadowRenderPassDescriptor = MTLRenderPassDescriptor()
  var shadowPipelineState: MTLRenderPipelineState!
  
  func buildTexture(pixelFormat: MTLPixelFormat,
                    size: CGSize,
                    label: String
  ) -> MTLTexture? {
    let width = Int(size.width)
    let height = Int(size.height)
    guard width > 0 && height > 0 else { return nil }
    
    let descriptor = MTLTextureDescriptor.texture2DDescriptor(
      pixelFormat: pixelFormat,
      width: width,
      height: height,
      mipmapped: false)
    descriptor.usage = [.shaderRead, .renderTarget]
    descriptor.storageMode = .private
    guard let texture =
            Renderer.device.makeTexture(descriptor: descriptor) else {
      fatalError()
    }
    texture.label = "\(label) texture"
    return texture
  }
  
  static var fps: Int!
  
  init(metalView: MTKView) {
    guard let device = MTLCreateSystemDefaultDevice(),
          let commandQueue = device.makeCommandQueue() else {
      fatalError("GPU not available")
    }
    
    Renderer.device = device
    Renderer.commandQueue = commandQueue
    Renderer.library = device.makeDefaultLibrary()
    Renderer.colorPixelFormat = metalView.colorPixelFormat
    Renderer.fps = metalView.preferredFramesPerSecond // default 60 fps (11.6ms)
    metalView.device = device
    metalView.depthStencilPixelFormat = .depth32Float
    depthStencilState = Renderer.buildDepthStencilState()!
    
    super.init()
    
    metalView.clearColor = MTLClearColor(red: 1.0, green: 1.0,
                                         blue: 0.8, alpha: 1.0)
    metalView.delegate = self
    mtkView(metalView, drawableSizeWillChange: metalView.bounds.size)
    buildShadowTexture(size: metalView.drawableSize)
    buildShadowPipelineState()
  }
  
  func buildShadowPipelineState() {
    let pipelineDescriptor = MTLRenderPipelineDescriptor()
    pipelineDescriptor.vertexFunction =
    Renderer.library.makeFunction(name: "vertex_depth")
    pipelineDescriptor.fragmentFunction = nil
    pipelineDescriptor.colorAttachments[0].pixelFormat = .invalid
    pipelineDescriptor.vertexDescriptor =
    MTKMetalVertexDescriptorFromModelIO(MDLVertexDescriptor.defaultVertexDescriptor)
    pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
    do {
      shadowPipelineState =
      try Renderer.device.makeRenderPipelineState(
        descriptor: pipelineDescriptor)
    } catch let error {
      fatalError(error.localizedDescription)
    }
  }
  
  func buildShadowTexture(size: CGSize) {
    shadowTexture = buildTexture(pixelFormat: .depth32Float,
                                 size: size, label: "Shadow")
    shadowRenderPassDescriptor.setUpDepthAttachment(
      texture: shadowTexture)
  }
  
  func renderShadowPass(renderEncoder: MTLRenderCommandEncoder) {
    guard
      let scene = scene,
    let sunlight = scene.lighting.lights.first(where: { $0.type == Sunlight })
    else { return }
    
    renderEncoder.pushDebugGroup("Shadow pass")
    renderEncoder.label = "Shadow encoder"
    renderEncoder.setCullMode(.none)
    renderEncoder.setDepthStencilState(depthStencilState)
    renderEncoder.setDepthBias(0.01, slopeScale: 1.0, clamp: 0.01)
    let orthoRect = CGRect(x: -8.0, y: 8.0, width: 16.0, height: 16.0)
    scene.uniforms.projectionMatrix = float4x4(orthographic: orthoRect, near: 0.1, far: 16)
    let position: float3 = [sunlight.position.x,
                            sunlight.position.y,
                            sunlight.position.z]
    let center: float3 = [0, 0, 0]
    let lookAt = float4x4(eye: position, center: center,
                          up: [0,1,0])
    scene.uniforms.viewMatrix = lookAt
    scene.uniforms.shadowMatrix =
    scene.uniforms.projectionMatrix * scene.uniforms.viewMatrix
    renderEncoder.setRenderPipelineState(shadowPipelineState)
    for renderable in scene.renderables {
      renderable.render(renderEncoder: renderEncoder,
                        uniforms: scene.uniforms)
    }
    renderEncoder.endEncoding()
    renderEncoder.popDebugGroup()
  }
}

extension Renderer: MTKViewDelegate {
  func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
    scene?.sceneSizeWillChange(to: size)
    buildShadowTexture(size: size)
  }
  
  func draw(in view: MTKView) {
    view.sampleCount = Renderer.antialiasingEnabled ? Renderer.antialiasingSampleCount : 1
    guard
      let scene = scene,
      let descriptor = view.currentRenderPassDescriptor,
      let commandBuffer = Renderer.commandQueue.makeCommandBuffer() else {
      return
    }
    
    // shadow pass
    guard let shadowEncoder = commandBuffer.makeRenderCommandEncoder( descriptor: shadowRenderPassDescriptor) else {
      return
    }
    renderShadowPass(renderEncoder: shadowEncoder)
    
    // main pass
    guard let renderEncoder = commandBuffer.makeRenderCommandEncoder( descriptor: descriptor) else {
      return
    }
    
    renderEncoder.pushDebugGroup("Main pass")
    renderEncoder.label = "Main encoder"
    
    let deltaTime = 1 / Float(Renderer.fps)
    scene.update(deltaTime: deltaTime)
    
    renderEncoder.setDepthStencilState(depthStencilState)
    
    var lights = scene.lighting.lights
    renderEncoder.setFragmentBytes(&lights, length: MemoryLayout<Light>.stride * lights.count, index: Int(BufferIndexLights.rawValue))
    
    renderEncoder.setFragmentTexture(shadowTexture, index: Int(BufferIndexShadow.rawValue))
    
    // render all the models in the array
    for renderable in scene.renderables {
      renderEncoder.pushDebugGroup(renderable.name)
      renderable.render(renderEncoder: renderEncoder,
                        uniforms: scene.uniforms,
                        fragmentUniforms: scene.fragmentUniforms)
      renderEncoder.popDebugGroup()
    }
    
    //        debugLights(renderEncoder: renderEncoder, lightType: Sunlight)
    //        debugLights(renderEncoder: renderEncoder, lightType: Pointlight)
    //        debugLights(renderEncoder: renderEncoder, lightType: Spotlight)
    
    // When objects are rendered, most of the skybox fragments will be behind them and will fail the depth test.
    // Therefore, it’s more efficient to render the skybox last.
    scene.skybox?.render(renderEncoder: renderEncoder, uniforms: scene.uniforms)
    
    renderEncoder.endEncoding()
    guard let drawable = view.currentDrawable else {
      return
    }
    commandBuffer.present(drawable)
    commandBuffer.commit()
  }
}

private extension MTLRenderPassDescriptor {
  func setUpDepthAttachment(texture: MTLTexture?) {
    guard let depthAttachmentTexture = texture else { return }
    
    depthAttachment.texture = depthAttachmentTexture
    depthAttachment.loadAction = .clear
    depthAttachment.storeAction = .store
    depthAttachment.clearDepth = 1
  }
}
